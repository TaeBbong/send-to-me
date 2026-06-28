import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/firebase/firebase_status.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/korean_text.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final firebaseReady = ref.watch(firebaseReadyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          if (!firebaseReady) const _FirebaseNotice(),

          _SectionHeader('자동 분류'),
          SwitchListTile(
            title: const Text('AI 자동 분류'),
            subtitle: const Text('저장한 메모를 배경에서 카테고리로 정리해요'),
            value: settings.autoClassify,
            onChanged: controller.setAutoClassify,
          ),
          SwitchListTile(
            title: const Text('새 카테고리 자동 생성'),
            subtitle: const Text('어울리는 분류가 없으면 새로 만들어요'),
            value: settings.autoCreateCategory,
            onChanged: settings.autoClassify
                ? controller.setAutoCreateCategory
                : null,
          ),
          SwitchListTile(
            title: const Text('참고자료 요약 생성'),
            subtitle: const Text('링크/자료 메모에 AI 요약을 붙여요'),
            value: settings.generateSummaries,
            onChanged: settings.autoClassify
                ? controller.setGenerateSummaries
                : null,
          ),
          ListTile(
            title: const Text('Gemini 모델'),
            subtitle: Text(settings.geminiModel),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _pickModel(context, ref, settings.geminiModel),
          ),

          const Divider(height: AppSpacing.xl),
          _SectionHeader('화면'),
          ListTile(
            title: const Text('테마'),
            subtitle: Text(_themeLabel(settings.themeMode)),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _pickTheme(context, ref, settings.themeMode),
          ),

          const Divider(height: AppSpacing.xl),
          _SectionHeader('정보'),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('앱 정보 · 개발자'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.about),
          ),
          const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Center(child: Text('v${AppConstants.appVersion}')),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.light => '라이트',
    ThemeMode.dark => '다크',
    ThemeMode.system => '시스템 설정 따름',
  };

  Future<void> _pickTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeMode current,
  ) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (ctx) => SafeArea(
        child: RadioGroup<ThemeMode>(
          groupValue: current,
          onChanged: (m) => Navigator.pop(ctx, m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final mode in ThemeMode.values)
                RadioListTile<ThemeMode>(
                  value: mode,
                  title: Text(_themeLabel(mode)),
                ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) {
      await ref.read(settingsControllerProvider.notifier).setThemeMode(selected);
    }
  }

  Future<void> _pickModel(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: RadioGroup<String>(
          groupValue: current,
          onChanged: (m) => Navigator.pop(ctx, m),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final model in AppConstants.selectableModels)
                if (model == AppConstants.defaultModel)
                  RadioListTile<String>(
                    value: model,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(model),
                    subtitle: const Text('기본값 · 무료 등급'),
                  )
                else
                  // Heavier models are gated behind a (future) paid tier:
                  // shown but disabled, with a lock and an explanatory tooltip.
                  RadioListTile<String>(
                    value: model,
                    enabled: false,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(model),
                    subtitle: const Text('유료 버전에서 사용할 수 있어요'),
                    secondary: Tooltip(
                      message: '유료 버전 결제 후 사용할 수 있어요',
                      triggerMode: TooltipTriggerMode.tap,
                      child: Icon(
                        Icons.lock_outline_rounded,
                        size: 20,
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) {
      await ref.read(settingsControllerProvider.notifier).setModel(selected);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.primary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _FirebaseNotice extends StatelessWidget {
  const _FirebaseNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.colors.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: context.colors.onErrorContainer),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              keepAll(
                'Firebase가 설정되지 않아 AI 기능이 꺼져 있어요. '
                'flutterfire configure로 연동하면 자동 분류가 켜집니다.',
              ),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colors.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
