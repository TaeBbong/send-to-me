import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../domain/entities/enums.dart';
import '../category_providers.dart';

/// Bottom sheet for creating a category by hand (보관함 FAB).
Future<void> showCreateCategorySheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _CreateCategorySheet(),
  );
}

class _CreateCategorySheet extends ConsumerStatefulWidget {
  const _CreateCategorySheet();

  @override
  ConsumerState<_CreateCategorySheet> createState() =>
      _CreateCategorySheetState();
}

class _CreateCategorySheetState extends ConsumerState<_CreateCategorySheet> {
  final _name = TextEditingController();
  final _emoji = TextEditingController();
  final _description = TextEditingController();
  CategoryKind _kind = CategoryKind.note;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _emoji.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    await ref.read(categoryActionsProvider).create(
          name: name,
          kind: _kind,
          emoji: _emoji.text,
          description: _description.text,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('새 카테고리', style: context.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64,
                child: TextField(
                  controller: _emoji,
                  textAlign: TextAlign.center,
                  maxLength: 2,
                  decoration: const InputDecoration(
                    labelText: '😀',
                    counterText: '',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _name,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _create(),
                  decoration: const InputDecoration(labelText: '이름'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('종류', style: context.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              for (final kind in CategoryKind.values)
                ChoiceChip(
                  label: Text('${kind.defaultEmoji} ${kind.label}'),
                  selected: _kind == kind,
                  onSelected: (_) => setState(() => _kind = kind),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _description,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: '설명 (선택)',
              hintText: '이 방에 어떤 메모가 들어갈지 — 분류 정확도에 도움돼요',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _name.text.trim().isEmpty ? null : _create,
              child: const Text('만들기'),
            ),
          ),
        ],
      ),
    );
  }
}
