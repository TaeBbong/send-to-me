import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart';

import '../../../core/firebase/firebase_status.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/enums.dart';
import '../../../domain/entities/memo.dart';
import '../widgets/kind_layouts.dart';
import 'firebase_ai_transport.dart';
import 'genui_cache_repository.dart';

/// Hosts a genui session for a category room.
///
/// The AI-rendered layout is generated **once** and cached (raw A2UI text). On
/// later visits the cached output is replayed locally — no LLM call, works
/// offline. If the memo set changed since caching, a "다시 생성" hint appears,
/// but the room is never silently regenerated.
class GenUiRoomView extends ConsumerStatefulWidget {
  const GenUiRoomView({
    super.key,
    required this.category,
    required this.memos,
    required this.modelName,
    required this.accent,
    required this.onRegenerate,
  });

  final Category category;
  final List<Memo> memos;
  final String modelName;
  final Color accent;

  /// Clears the cache and rebuilds this view (wired by the parent screen).
  final VoidCallback onRegenerate;

  @override
  ConsumerState<GenUiRoomView> createState() => _GenUiRoomViewState();
}

class _GenUiRoomViewState extends ConsumerState<GenUiRoomView> {
  SurfaceController? _controller;
  FirebaseAiTransport? _transport;
  A2uiTransportAdapter? _replayAdapter;
  final List<StreamSubscription<dynamic>> _subs = [];
  final List<String> _surfaceIds = [];

  bool _processing = true;
  bool _failed = false;
  bool _stale = false;
  String? _fallbackNote;

  @override
  void initState() {
    super.initState();
    unawaited(_setup());
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _controller?.dispose();
    _transport?.dispose();
    _replayAdapter?.dispose();
    super.dispose();
  }

  Future<void> _setup() async {
    final signature = _signature(widget.memos);
    final cache = await ref.read(genUiCacheRepositoryProvider).get(
      widget.category.id,
    );
    if (!mounted) return;

    if (cache != null && cache.payload.trim().isNotEmpty) {
      setState(() => _stale = cache.signature != signature);
      _replay(cache.payload);
      return;
    }

    if (!ref.read(firebaseReadyProvider)) {
      setState(() {
        _failed = true;
        _processing = false;
      });
      return;
    }
    await _generate(signature);
  }

  Catalog _catalog() =>
      BasicCatalogItems.asCatalog(systemPromptFragments: [_kindGuidance()]);

  /// Re-renders previously generated UI without any network/LLM call.
  void _replay(String payload) {
    try {
      final controller = SurfaceController(catalogs: [_catalog()]);
      final adapter = A2uiTransportAdapter();
      _subs.add(adapter.incomingMessages.listen(controller.handleMessage));
      _subs.add(controller.surfaceUpdates.listen(_onSurfaceUpdate));
      _controller = controller;
      _replayAdapter = adapter;
      adapter.addChunk(payload);

      // Safety: stop the spinner shortly after feeding, in case the cached
      // payload yields no surfaces (corrupt cache → fall back).
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _processing = false);
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          _processing = false;
        });
      }
    }
  }

  /// Calls Gemini once, renders the stream, and persists the output.
  Future<void> _generate(String signature) async {
    try {
      final catalog = _catalog();
      final controller = SurfaceController(catalogs: [catalog]);
      final transport = FirebaseAiTransport(
        modelName: widget.modelName,
        systemInstruction: PromptBuilder.chat(
          catalog: catalog,
        ).systemPromptJoined(),
      );
      _subs.add(transport.incomingMessages.listen(controller.handleMessage));
      _subs.add(controller.surfaceUpdates.listen(_onSurfaceUpdate));
      _subs.add(
        controller.onSubmit.listen((m) => unawaited(transport.sendRequest(m))),
      );
      _controller = controller;
      _transport = transport;

      await transport.sendRequest(ChatMessage.user(_userPrompt()));

      final output = transport.capturedOutput;
      if (output.trim().isNotEmpty) {
        await ref
            .read(genUiCacheRepositoryProvider)
            .save(widget.category.id, output, signature);
      }
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _onSurfaceUpdate(SurfaceUpdate update) {
    if (!mounted) return;
    switch (update) {
      case SurfaceAdded(:final surfaceId):
        setState(() {
          if (!_surfaceIds.contains(surfaceId)) _surfaceIds.add(surfaceId);
          _processing = false;
        });
      case SurfaceRemoved(:final surfaceId):
        setState(() => _surfaceIds.remove(surfaceId));
      case ComponentsUpdated():
        setState(() {});
    }
  }

  /// Stable fingerprint of the memo set; changes when memos are added/edited or
  /// their done-state flips, so we can flag the cached UI as stale.
  String _signature(List<Memo> memos) {
    final parts =
        memos
            .map((m) => '${m.id}:${m.isDone}:${m.content.hashCode}')
            .toList()
          ..sort();
    return parts.join('|').hashCode.toString();
  }

  String _kindGuidance() {
    const base =
        'You are rendering the contents of a single note category as ONE UI '
        'surface. Be concise; do not ask the user questions. Do NOT include a '
        'title, heading, or the category name in the surface — the screen '
        'already shows it in the app bar. Start directly with the content.';
    return switch (widget.category.kind) {
      CategoryKind.todo => '$base Present the items as a checklist using '
          'CheckBox components, one per memo.',
      CategoryKind.reference =>
        '$base Present each memo as a Card with its title/summary and, if a URL '
            'is present, a button to open it.',
      CategoryKind.idea => '$base Present the memos as a vertical, '
          'time-ordered list of Cards (a timeline of ideas).',
      CategoryKind.note =>
        '$base Present the memos as a clean vertical list of text items.',
    };
  }

  String _userPrompt() {
    final payload = widget.memos
        .map(
          (m) => {
            'id': m.id,
            'content': m.content,
            'isDone': m.isDone,
            if (m.summary != null) 'summary': m.summary,
            if (m.sourceUrl != null) 'sourceUrl': m.sourceUrl,
            'createdAt': m.createdAt.toIso8601String(),
          },
        )
        .toList();
    return 'Category "${widget.category.name}" (kind: ${widget.category.kind.name}). '
        'Build a single surface that best presents these memos.\n'
        'Memos JSON:\n${jsonEncode(payload)}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    if (_failed) {
      return _Fallback(
        category: widget.category,
        memos: widget.memos,
        accent: widget.accent,
        note: 'AI 화면을 불러오지 못해 기본 보기로 표시했어요.',
      );
    }
    if (_processing && _surfaceIds.isEmpty) {
      return const _GeneratingIndicator();
    }
    if (controller == null || _surfaceIds.isEmpty) {
      return _Fallback(
        category: widget.category,
        memos: widget.memos,
        accent: widget.accent,
        note: _fallbackNote ?? 'AI가 생성한 화면이 없어 기본 보기로 표시했어요.',
      );
    }

    return Column(
      children: [
        if (_stale) _StaleBanner(onRegenerate: widget.onRegenerate),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: _surfaceIds.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Surface(
                surfaceContext: controller.contextFor(_surfaceIds[index]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StaleBanner extends StatelessWidget {
  const _StaleBanner({required this.onRegenerate});

  final VoidCallback onRegenerate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: context.colors.primary.withValues(alpha: 0.10),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 4, AppSpacing.sm, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '메모가 바뀌었어요. 화면을 다시 만들까요?',
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colors.primary,
              ),
            ),
          ),
          TextButton(
            onPressed: onRegenerate,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              minimumSize: const Size(0, 32),
            ),
            child: const Text('다시 생성'),
          ),
        ],
      ),
    );
  }
}

class _GeneratingIndicator extends StatelessWidget {
  const _GeneratingIndicator();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('AI가 이 방의 화면을 구성하고 있어요…', style: context.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({
    required this.category,
    required this.memos,
    required this.accent,
    this.note,
  });

  final Category category;
  final List<Memo> memos;
  final Color accent;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (note != null)
          Container(
            width: double.infinity,
            color: context.appColors.systemBubble,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: Text(
              note!,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.appColors.onSystemBubble,
              ),
            ),
          ),
        Expanded(
          child: KindMemoLayout(
            kind: category.kind,
            memos: memos,
            accent: accent,
          ),
        ),
      ],
    );
  }
}
