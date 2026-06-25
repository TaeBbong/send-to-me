import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/enums.dart';
import '../../domain/entities/memo.dart';
import '../constants/app_constants.dart';
import '../providers/app_providers.dart';

const _uuid = Uuid();

/// Development-only startup tasks, run from `main()` when [Env.isDev].
///
///  * Replays onboarding on every launch (so it's easy to iterate on), and
///  * seeds a handful of categories/memos when the database is empty — so a
///    fresh install (which wipes data) immediately has something to test with.
///
/// Both are no-ops in production builds, which never call this.
Future<void> runDevBootstrap(
  ProviderContainer container,
  SharedPreferences prefs,
) async {
  // Always show onboarding again in dev.
  await prefs.setBool(PrefKeys.onboardingDone, false);

  final categoryRepo = container.read(categoryRepositoryProvider);
  final existing = (await categoryRepo.getAll()).valueOrNull ?? const [];
  if (existing.isNotEmpty) return; // already has data — don't double-seed

  final memoRepo = container.read(memoRepositoryProvider);
  final now = DateTime.now();

  // A category created `daysAgo` days ago, plus a small minute offset so the
  // room ordering is stable and not all identical.
  Category cat(String name, String emoji, CategoryKind kind, String about,
      int daysAgo) {
    final ts = now.subtract(Duration(days: daysAgo));
    return Category(
      id: _uuid.v4(),
      name: name,
      emoji: emoji,
      kind: kind,
      description: about,
      createdAt: ts,
      updatedAt: ts,
    );
  }

  Memo memo(
    String categoryId,
    String content, {
    int minutesAgo = 0,
    bool isDone = false,
    String? summary,
    String? sourceUrl,
    String? linkTitle,
    Duration? dueIn,
  }) {
    final created = now.subtract(Duration(minutes: minutesAgo));
    return Memo(
      id: _uuid.v4(),
      content: content,
      status: MemoStatus.classified,
      createdAt: created,
      categoryId: categoryId,
      summary: summary,
      sourceUrl: sourceUrl,
      linkTitle: linkTitle,
      isDone: isDone,
      doneAt: isDone ? created.add(const Duration(minutes: 5)) : null,
      dueAt: dueIn == null ? null : now.add(dueIn),
      classifiedAt: created,
    );
  }

  final todo = cat('할 일', '✅', CategoryKind.todo, '처리해야 할 자잘한 일들', 3);
  final ref =
      cat('참고자료', '🔖', CategoryKind.reference, '나중에 다시 볼 링크와 자료', 2);
  final idea = cat('아이디어', '💡', CategoryKind.idea, '떠오른 생각과 메모', 1);
  final note = cat('메모', '📝', CategoryKind.note, '그 외 일반 메모', 1);

  for (final c in [todo, ref, idea, note]) {
    await categoryRepo.add(c);
  }

  final memos = <Memo>[
    memo(todo.id, '우유랑 계란 사기', minutesAgo: 600),
    memo(todo.id, '이력서 PDF로 내보내기', minutesAgo: 540, isDone: true),
    memo(todo.id, '치과 예약 전화하기', minutesAgo: 120, dueIn: const Duration(days: 2)),
    memo(
      ref.id,
      'https://flutter.dev/',
      minutesAgo: 480,
      sourceUrl: 'https://flutter.dev/',
      linkTitle: 'Flutter - Build apps for any screen',
      summary: '구글의 크로스플랫폼 UI 툴킷 공식 사이트.',
    ),
    memo(
      ref.id,
      'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      minutesAgo: 90,
      sourceUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
      linkTitle: 'Rick Astley - Never Gonna Give You Up · Rick Astley',
    ),
    memo(idea.id, '메모 앱에 음성 입력을 붙이면 운전 중에도 쓸 수 있겠다', minutesAgo: 300),
    memo(idea.id, '주말에 갈 만한 근교 등산 코스 정리해보기', minutesAgo: 60),
    memo(note.id, '회의 메모: 다음 스프린트는 검색 기능을 먼저 작업하기로 함', minutesAgo: 200),
    memo(note.id, '엄마 생신 6월 30일 — 선물 미리 챙기기', minutesAgo: 30),
  ];

  for (final m in memos) {
    await memoRepo.add(m);
  }
}
