import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../features/settings/settings_controller.dart';
import '../features/sharing/share_intent_listener.dart';
import 'app_router.dart';

/// Root widget: wires the router and the light/dark theme driven by settings.
class AwesomeMemoApp extends ConsumerWidget {
  const AwesomeMemoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(
      settingsControllerProvider.select((s) => s.themeMode),
    );

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) =>
          ShareIntentListener(child: child ?? const SizedBox.shrink()),
    );
  }
}
