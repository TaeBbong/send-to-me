import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/theme_extensions.dart';

/// App + developer information ("개발자 정보"), with how-it-works copy.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('앱 정보')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: context.colors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: const Icon(
                    Icons.bubble_chart_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(AppConstants.appName, style: context.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppConstants.appTagline,
                  style: context.textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'v${AppConstants.appVersion}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          _Section(
            title: '어떻게 동작하나요',
            child: Text(
              '메모를 채팅하듯 툭 던지면 곧바로 저장돼요. 잠시 뒤 AI가 배경에서 '
              '내용을 살펴보고 어울리는 카테고리로 분류하거나, 마땅한 분류가 없으면 '
              '새 카테고리를 만들어 채팅방처럼 모아둡니다. 각 방은 카테고리 성격에 '
              '맞춰 생성형 UI로 다르게 표시돼요.',
              style: context.textTheme.bodyMedium,
            ),
          ),

          _Section(
            title: '개발자',
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text(AppConstants.developerName),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.mail_outline_rounded),
                  title: const Text(AppConstants.developerEmail),
                  onTap: () => _launch('mailto:${AppConstants.developerEmail}'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.code_rounded),
                  title: const Text('소스 코드'),
                  subtitle: const Text(AppConstants.repositoryUrl),
                  onTap: () => _launch(AppConstants.repositoryUrl),
                ),
              ],
            ),
          ),

          _Section(
            title: '기술 스택',
            child: Text(
              'Flutter · Riverpod · Drift(로컬 우선) · Firebase AI Logic(Gemini) · '
              'genui(생성형 UI). 클린 아키텍처로 구성했습니다.',
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colors.primary,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}
