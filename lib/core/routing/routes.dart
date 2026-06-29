/// Centralized route path definitions for the application.
///
/// Using constants prevents typos and makes route refactoring easier.
abstract final class AppRoutes {
  AppRoutes._();

  /// Home / browse screen.
  static const String home = '/';

  /// House details screen, requires an `id` path parameter.
  static const String houseDetails = '/house/:id';

  /// Registration screen for landlords and property agents.
  static const String landlordRegistration = '/landlord/register';

  /// Phone verification screen after landlord registration.
  static const String phoneVerification = '/landlord/verify-phone';

  /// Dashboard where landlords manage their listings.
  static const String landlordDashboard = '/landlord/dashboard';

  /// Listing creation screen for landlords.
  static const String createListing = '/landlord/listings/create';

  /// Helper to build a concrete house details path from an [id].
  static String houseDetailsPath(String id) => '/house/$id';
}
