/// Centralized route paths and names for go_router.
abstract final class AppRoutes {
  static const String chat = '/chat';
  static const String rooms = '/rooms';

  /// Hidden chat rooms list. Nested under [rooms].
  static const String hidden = 'hidden';
  static const String hiddenPath = '/rooms/hidden';

  /// Category detail. Use [roomPath] to build the concrete path.
  static const String room = 'room';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String onboarding = '/onboarding';

  static String roomPath(String categoryId) => '/rooms/$categoryId';
}
