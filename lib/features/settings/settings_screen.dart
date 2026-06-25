import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/firebase/firebase_status.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/korean_text.dart';
import '../quick_capture/quick_capture_service.dart';
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

          if (Platform.isIOS || Platform.isAndroid) ...[
            const Divider(height: AppSpacing.xl),
            _SectionHeader('빠른 메모'),
            ListTile(
              leading: const Icon(Icons.bolt_rounded),
              title: const Text('앱 밖에서 바로 메모하기'),
              subtitle: Text(
                Platform.isIOS
                    ? '폰 뒷면 탭·액션 버튼으로 입력창 열기'
                    : '알림창 타일로 어디서든 입력창 열기',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showQuickCaptureGuide(context),
            ),
            if (Platform.isAndroid)
              ListTile(
                leading: const Icon(Icons.accessibility_new_rounded),
                title: const Text('접근성 단축키로 열기'),
                subtitle: const Text('접근성 버튼·볼륨 키·제스처로 입력창 열기'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showAccessibilityGuide(context, ref),
              ),
          ],

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

  Future<void> _showAccessibilityGuide(BuildContext context, WidgetRef ref) {
    final service = ref.read(quickCaptureServiceProvider);
    const steps = [
      '아래 \'접근성 설정 열기\'를 눌러요.',
      '\'빠른 메모 (접근성 단축키)\'를 켜요.',
      '단축키 방식(접근성 버튼 / 볼륨 키 두 개 길게 / 제스처)을 골라요.',
      '이제 그 단축키를 쓰면 어디서든 입력창이 떠요.',
    ];

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('접근성 단축키로 메모 열기', style: ctx.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              // Prominent disclosure (required for the AccessibilityService API).
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: ctx.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  keepAll(
                    '이 기능을 켜면 접근성 서비스가 등록돼요. 접근성 버튼·볼륨 키·'
                    '제스처로 빠른 메모 입력창을 여는 용도로만 쓰이고, '
                    '화면 내용은 절대 읽지 않아요.',
                  ),
                  style: ctx.textTheme.bodySmall?.copyWith(
                    color: ctx.appColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (var i = 0; i < steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: ctx.colors.primary,
                        child: Text(
                          '${i + 1}',
                          style: ctx.textTheme.labelSmall?.copyWith(
                            color: ctx.colors.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          keepAll(steps[i]),
                          style: ctx.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.settings_accessibility_rounded),
                  label: const Text('접근성 설정 열기'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    service.openAccessibilitySettings();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showQuickCaptureGuide(BuildContext context) {
    final steps = Platform.isIOS
        ? const [
            '단축어 앱을 열고 \'나에게 보내기 > 빠른 메모\' 동작을 찾아요.',
            '설정 > 손쉬운 사용 > 터치 > 뒷면 탭에서 \'두 번 탭\'에 그 단축어를 지정해요.',
            '이제 폰 뒷면을 두 번 톡톡 치면, 앱을 열지 않아도 입력창이 떠서 바로 저장돼요.',
            '액션 버튼(15 Pro 이상)이나 제어 센터에도 같은 단축어를 넣을 수 있어요.',
          ]
        : const [
            '알림창(상단바)을 끝까지 내린 뒤 연필 모양 편집 버튼을 눌러요.',
            '타일 목록에서 \'빠른 메모\'를 끌어다 추가해요.',
            '이제 알림창의 타일을 누르면 어디서든 입력창이 떠요.',
            '(삼성) 설정 > 유용한 기능 > 사이드 버튼 > 두 번 누르기를 \'앱 열기 > 나에게 보내기\'로 지정하면 버튼으로도 열려요.',
          ];

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Platform.isIOS ? '폰 뒷면 탭으로 메모하기' : '알림창 타일로 메모하기',
                style: ctx.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: ctx.colors.primary,
                        child: Text(
                          '${i + 1}',
                          style: ctx.textTheme.labelSmall?.copyWith(
                            color: ctx.colors.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          keepAll(steps[i]),
                          style: ctx.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
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
