import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/widgets/empty_state.dart';
import 'category_providers.dart';
import 'widgets/category_room_tile.dart';
import 'widgets/create_category_sheet.dart';

/// The messenger "chat room list" — one room per category. Rooms appear and
/// reorder themselves as the classifier files memos away.
class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final hiddenCount =
        ref.watch(archivedCategoriesProvider).valueOrNull?.length ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('보관함')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateCategorySheet(context),
        tooltip: '새 카테고리',
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('카테고리를 불러오지 못했어요: $e')),
        data: (categories) {
          if (categories.isEmpty && hiddenCount == 0) {
            return const EmptyState(
              icon: Icons.forum_outlined,
              title: '아직 분류가 없어요',
              message: '메모를 남기면 AI가 어울리는 카테고리를 만들어\n여기 채팅방처럼 모아둘게요.',
            );
          }
          final hasHidden = hiddenCount > 0;
          // The hidden-rooms entry occupies index 0 when present, with the
          // category rows shifted down by one.
          final itemCount = categories.length + (hasHidden ? 1 : 0);
          return ListView.separated(
            itemCount: itemCount,
            separatorBuilder: (_, _) => Divider(
              indent: 80,
              color: context.appColors.divider,
            ),
            itemBuilder: (context, index) {
              if (hasHidden && index == 0) {
                return _HiddenRoomsEntry(count: hiddenCount);
              }
              final category = categories[index - (hasHidden ? 1 : 0)];
              return CategoryRoomTile(category);
            },
          );
        },
      ),
    );
  }
}

/// The "숨겨진 채팅방" entry row shown atop the list when hidden rooms exist.
class _HiddenRoomsEntry extends StatelessWidget {
  const _HiddenRoomsEntry({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return InkWell(
      onTap: () => context.push(AppRoutes.hiddenPath),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: c.divider.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.visibility_off_outlined, color: c.textSecondary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                '숨겨진 채팅방',
                style: context.textTheme.titleSmall,
              ),
            ),
            Text(
              '$count',
              style: context.textTheme.labelMedium?.copyWith(
                color: c.textSecondary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: c.textSecondary),
          ],
        ),
      ),
    );
  }
}
