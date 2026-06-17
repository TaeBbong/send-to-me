import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_extensions.dart';
import '../../core/widgets/empty_state.dart';
import 'category_providers.dart';
import 'widgets/category_room_tile.dart';

/// The messenger "chat room list" — one room per category. Rooms appear and
/// reorder themselves as the classifier files memos away.
class CategoryListScreen extends ConsumerWidget {
  const CategoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('보관함')),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('카테고리를 불러오지 못했어요: $e')),
        data: (categories) {
          if (categories.isEmpty) {
            return const EmptyState(
              icon: Icons.forum_outlined,
              title: '아직 분류가 없어요',
              message: '메모를 남기면 AI가 어울리는 카테고리를 만들어\n여기 채팅방처럼 모아둘게요.',
            );
          }
          return ListView.separated(
            itemCount: categories.length,
            separatorBuilder: (_, _) => Divider(
              indent: 80,
              color: context.appColors.divider,
            ),
            itemBuilder: (context, index) =>
                CategoryRoomTile(categories[index]),
          );
        },
      ),
    );
  }
}
