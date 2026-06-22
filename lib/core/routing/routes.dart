/// Centralized route path definitions for the application.
///
/// Using constants prevents typos and makes route refactoring easier.
abstract final class AppRoutes {
  AppRoutes._();

  /// Home / browse screen.
  static const String home = '/';

  /// House details screen, requires an `id` path parameter.
  static const String houseDetails = '/house/:id';

  /// Helper to build a concrete house details path from an [id].
  static String houseDetailsPath(String id) => '/house/$id';
}
