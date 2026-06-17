import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';
import '../core/providers/app_providers.dart';
import '../core/router/app_routes.dart';
import '../features/about/about_screen.dart';
import '../features/categories/category_list_screen.dart';
import '../features/category_detail/category_detail_screen.dart';
import '../features/memo_chat/memo_chat_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/settings/settings_screen.dart';
import 'app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// The app's [GoRouter], with a one-time onboarding gate and a bottom-nav shell.
final routerProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.chat,
    redirect: (context, state) {
      final done = prefs.getBool(PrefKeys.onboardingDone) ?? false;
      final atOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!done && !atOnboarding) return AppRoutes.onboarding;
      if (done && atOnboarding) return AppRoutes.chat;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.chat,
                builder: (context, state) => const MemoChatScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.rooms,
                builder: (context, state) => const CategoryListScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    name: AppRoutes.room,
                    builder: (context, state) => CategoryDetailScreen(
                      categoryId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('${AppConstants.appName}: 경로를 찾을 수 없어요')),
    ),
  );
});
