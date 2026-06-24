import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_extensions.dart';
import '../../core/widgets/empty_state.dart';
import 'category_providers.dart';
import 'widgets/category_room_tile.dart';

/// The "hidden chat rooms" view. Lists categories the user has hidden from the
/// main list; long-pressing a row offers "다시 보이기" to bring it back.
class HiddenCategoriesScreen extends ConsumerWidget {
  const HiddenCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(archivedCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('숨겨진 채팅방')),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오지 못했어요: $e')),
        data: (categories) {
          if (categories.isEmpty) {
            return const EmptyState(
              icon: Icons.visibility_off_outlined,
              title: '숨긴 채팅방이 없어요',
              message: '채팅방을 길게 눌러 숨기면\n여기에서 다시 꺼낼 수 있어요.',
            );
          }
          return ListView.separated(
            itemCount: categories.length,
            separatorBuilder: (_, _) => Divider(
              indent: 80,
              color: context.appColors.divider,
            ),
            itemBuilder: (context, index) =>
                CategoryRoomTile(categories[index], isHidden: true),
          );
        },
      ),
    );
  }
}
