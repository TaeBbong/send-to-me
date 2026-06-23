import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_extensions.dart';
import '../../core/utils/korean_text.dart';

/// A lightweight 3-step intro shown once on first launch.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardData(
      icon: Icons.bolt_rounded,
      title: '생각나면 톡 던지세요',
      body: '메신저에 메시지 보내듯, 떠오르는 메모를 그냥 적어 보세요.\n저장은 즉시, 고민은 0초.',
    ),
    _OnboardData(
      icon: Icons.auto_awesome_rounded,
      title: '정리는 AI가 알아서',
      body: '저장한 메모를 배경에서 분석해 어울리는 카테고리로 분류해요.\n없으면 새 분류를 만들어 둡니다.',
    ),
    _OnboardData(
      icon: Icons.dashboard_customize_rounded,
      title: '카테고리마다 다른 화면',
      body: '할 일은 체크리스트로, 자료는 요약 카드로.\n생성형 UI가 방마다 어울리는 모습으로 보여줘요.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool(PrefKeys.onboardingDone, true);
    if (mounted) context.go(AppRoutes.chat);
  }

  void _next() {
    if (_page == _pages.length - 1) {
      _finish();
    } else {
      _pageController.nextPage(
        duration: AppDurations.normal,
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('건너뛰기'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _OnboardPage(_pages[index]),
              ),
            ),
            _Dots(count: _pages.length, active: _page),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(isLast ? '시작하기' : '다음'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  const _OnboardData({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
}

class _OnboardPage extends StatelessWidget {
  const _OnboardPage(this.data);
  final _OnboardData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 52, color: context.colors.primary),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            keepAll(data.title),
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            keepAll(data.body),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});
  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: AppDurations.fast,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == active ? 18 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == active
                  ? context.colors.primary
                  : context.appColors.divider,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
      ],
    );
  }
}
