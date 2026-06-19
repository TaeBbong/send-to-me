import 'dart:async';
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../core/utils/diagnostic_log.dart';
import '../../core/utils/url_detector.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/classification_result.dart';

/// Calls Firebase AI Logic (Gemini) to classify a memo against the user's
/// existing categories, using structured JSON output.
///
/// Resilience built in:
///  * primary model → [AppConstants.fallbackModel] on first failure,
///  * lenient JSON parsing ([ClassificationResult.fromJson]),
///  * everything wrapped in [Result] so the worker never throws.
class ClassificationService {
  const ClassificationService();

  /// JSON schema the model must conform to. All fields optional so the model
  /// can express either "matched existing" or "create new".
  static final Schema _responseSchema = Schema.object(
    properties: {
      'matchedCategoryId': Schema.string(
        description:
            'The id of an existing category this memo belongs to. Omit or '
            'leave empty to create a new category instead.',
      ),
      'newCategoryName': Schema.string(
        description: 'Short name (1-3 words) for a NEW category, in the '
            "user's language. Only when nothing matches.",
      ),
      'newCategoryEmoji': Schema.string(
        description: 'A single emoji representing the new category.',
      ),
      'newCategoryKind': Schema.enumString(
        enumValues: ['todo', 'reference', 'idea', 'note'],
        description: 'The personality of the new category.',
      ),
      'newCategoryDescription': Schema.string(
        description:
            'One sentence describing what belongs in the new category, used '
            'to match future memos.',
      ),
      'summary': Schema.string(
        description:
            'A concise 1-2 sentence summary, mainly for reference/link memos.',
      ),
      'sourceUrl': Schema.string(
        description: 'A URL found in the memo, if any.',
      ),
      'isDone': Schema.boolean(
        description: 'For a task, whether it already reads as completed.',
      ),
      'dueAt': Schema.string(
        description: 'An ISO-8601 due date/time if the memo mentions one.',
      ),
    },
    optionalProperties: [
      'matchedCategoryId',
      'newCategoryName',
      'newCategoryEmoji',
      'newCategoryKind',
      'newCategoryDescription',
      'summary',
      'sourceUrl',
      'isDone',
      'dueAt',
    ],
  );

  static const String _systemInstruction = '''
You are the classification engine of a personal memo app. The user "tosses" a
short memo and you decide where it belongs.

Output ONLY JSON matching the provided schema. Decide between two outcomes:
1) Match an EXISTING category — set "matchedCategoryId" to its id.
2) Create a NEW category — leave "matchedCategoryId" empty and fill the
   "newCategory*" fields.

Rules (apply in order):
- LINKS FIRST: if the memo is primarily a URL/link or a resource to save (a
  video, article, repo, product page, etc.), it MUST be filed under a
  "reference" category and you MUST provide a short "summary". Match an existing
  reference category only if it genuinely fits; otherwise CREATE a new reference
  category. NEVER put a link into a "note", "todo", or "idea" category, and
  never treat a link as a plain note — this overrides the preference below.
- Otherwise, STRONGLY prefer matching an existing category when it is
  semantically appropriate. Only create a new category when none reasonably fit.
- Category kinds: "todo" (actionable tasks), "reference" (links/resources to
  revisit), "idea" (thoughts, journaling), "note" (general catch-all for plain
  text that has no link and no clear action).
- For task-like memos, set "isDone" if it already reads as completed, and set
  "dueAt" (ISO-8601) if a date/time is mentioned.
- Category names must be BROAD and REUSABLE so many future memos group together
  (e.g. "할 일", "집안일", "쇼핑", "아이디어"). NEVER name a category after one
  memo's specific content. For example "빨래하기" and "설거지하기" are both
  everyday chores and belong in ONE general category like "할 일" (or "집안일");
  do NOT create separate "빨래"/"설거지" categories.
- For simple actionable tasks/chores, strongly prefer a single general "todo"
  category (e.g. "할 일") over creating a new category per task.
- Keep "newCategoryName" short (1-3 words), in the user's language, with a
  fitting "newCategoryEmoji".
''';

  GenerativeModel _model(String modelName) {
    return FirebaseAI.googleAI().generativeModel(
      model: modelName,
      systemInstruction: Content.system(_systemInstruction),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: _responseSchema,
        temperature: 0.2,
        // Classification is a simple, low-reasoning task. Minimizing "thinking"
        // is the single biggest latency win on flash models — Gemini 3.x uses
        // thinking levels, 2.5 and earlier use a numeric budget.
        thinkingConfig: _minimalThinking(modelName),
      ),
    );
  }

  /// Returns the lowest-latency thinking setting valid for [modelName], or null
  /// to leave the model default (Pro models can't fully disable thinking).
  ThinkingConfig? _minimalThinking(String modelName) {
    if (modelName.contains('pro')) return null;
    final isGemini3OrNewer = RegExp(r'gemini-([3-9]|\d{2,})').hasMatch(modelName);
    return isGemini3OrNewer
        ? ThinkingConfig.withThinkingLevel(ThinkingLevel.minimal)
        : ThinkingConfig.withThinkingBudget(0);
  }

  String _buildPrompt({
    required String content,
    required List<Category> existing,
    required bool allowNewCategory,
    required bool generateSummary,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('## Existing categories');
    if (existing.isEmpty) {
      buffer.writeln('(none yet — you will likely create the first category)');
    } else {
      for (final c in existing) {
        buffer.writeln(
          '- id: ${c.id} | name: ${c.name} | kind: ${c.kind.name} | '
          'about: ${c.description}',
        );
      }
    }
    buffer.writeln();
    buffer.writeln('## New memo');
    buffer.writeln(content);

    final url = UrlDetector.firstUrl(content);
    if (url != null) {
      buffer.writeln(
        '\n(Detected URL: $url — this memo contains a link, so it MUST go to a '
        '"reference" category, never a note/todo/idea.)',
      );
    }
    if (!allowNewCategory && existing.isNotEmpty) {
      buffer.writeln(
        '\nConstraint: do NOT create a new category. Choose the closest '
        'existing category id.',
      );
    }
    if (!generateSummary) {
      buffer.writeln('\nDo not produce a "summary".');
    }
    return buffer.toString();
  }

  Future<Result<ClassificationResult>> classify({
    required String content,
    required List<Category> existing,
    required String modelName,
    required bool allowNewCategory,
    required bool generateSummary,
  }) async {
    final prompt = _buildPrompt(
      content: content,
      existing: existing,
      allowNewCategory: allowNewCategory,
      generateSummary: generateSummary,
    );

    final sw = Stopwatch()..start();
    DiagnosticLog.instance.log('[AICLASSIFY] start model=$modelName contentLen=${content.length}');
    try {
      final text = await _generateWithFallback(modelName, prompt);
      DiagnosticLog.instance.log(
        '[AICLASSIFY] response in ${sw.elapsedMilliseconds}ms '
        'len=${text?.length ?? 0}',
      );
      if (text == null || text.trim().isEmpty) {
        return const Result.err(LlmFailure('LLM이 빈 응답을 반환했어요.'));
      }
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        return const Result.err(LlmFailure('LLM 응답 형식이 올바르지 않아요.'));
      }
      return Result.ok(ClassificationResult.fromJson(decoded));
    } on TimeoutException {
      DiagnosticLog.instance.log('[AICLASSIFY] TIMEOUT after ${sw.elapsedMilliseconds}ms');
      return const Result.err(LlmFailure('분류 시간이 초과됐어요. 다시 시도해 주세요.'));
    } on FormatException catch (e) {
      DiagnosticLog.instance.log('[AICLASSIFY] FORMAT error ${sw.elapsedMilliseconds}ms: $e');
      return Result.err(LlmFailure('LLM 응답 파싱 실패', cause: e));
    } on FirebaseException catch (e) {
      DiagnosticLog.instance.log(
        '[AICLASSIFY] FIREBASE error ${sw.elapsedMilliseconds}ms '
        'plugin=${e.plugin} code=${e.code} msg=${e.message}',
      );
      return Result.err(LlmFailure('Firebase AI 호출 실패: ${e.message}', cause: e));
    } catch (e) {
      DiagnosticLog.instance.log(
        '[AICLASSIFY] UNKNOWN error ${sw.elapsedMilliseconds}ms '
        '${e.runtimeType}: $e',
      );
      return Result.err(LlmFailure('분류 중 알 수 없는 오류', cause: e));
    }
  }

  /// Each attempt is bounded by [AppConstants.classifyTimeout]. A timeout is
  /// usually a dead idle keep-alive socket, so we retry the same model once
  /// (which establishes a fresh connection). Non-timeout errors fall back to
  /// [AppConstants.fallbackModel] once.
  Future<String?> _generateWithFallback(String modelName, String prompt) async {
    Future<String?> run(String model) => _model(model)
        .generateContent([Content.text(prompt)])
        .timeout(AppConstants.classifyTimeout)
        .then((resp) => resp.text);

    try {
      return await run(modelName);
    } on TimeoutException {
      DiagnosticLog.instance.log('[AICLASSIFY] timeout → retrying once on a fresh connection');
      return await run(modelName);
    } catch (_) {
      if (modelName == AppConstants.fallbackModel) rethrow;
      return await run(AppConstants.fallbackModel);
    }
  }
}
