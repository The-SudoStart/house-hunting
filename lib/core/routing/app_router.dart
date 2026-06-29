import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/models/landlord_registration_data.dart';
import '../../features/auth/screens/landlord_registration_screen.dart';
import '../../features/auth/screens/phone_verification_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/house_details/screens/house_details_screen.dart';
import '../../features/landlord/screens/create_listing_screen.dart';
import '../../features/landlord/screens/landlord_dashboard_screen.dart';
import 'routes.dart';

/// Application router configuration using go_router.
///
/// The router is designed to be easily extendable as new screens are added.
/// To add a new route:
/// 1. Define a path constant in [AppRoutes].
/// 2. Add a [GoRoute] entry below.
/// 3. Create the target screen widget.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.home,
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.houseDetails,
      builder: (BuildContext context, GoRouterState state) {
        // Expects `id` as a path parameter, e.g. /house/123
        final String houseId = state.pathParameters['id'] ?? '';
        return HouseDetailsScreen(houseId: houseId);
      },
    ),
    GoRoute(
      path: AppRoutes.landlordRegistration,
      builder: (BuildContext context, GoRouterState state) {
        return const LandlordRegistrationScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.phoneVerification,
      builder: (BuildContext context, GoRouterState state) {
        final extra = state.extra;
        return PhoneVerificationScreen(
          registrationData:
              extra is LandlordRegistrationData ? extra : null,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.landlordDashboard,
      builder: (BuildContext context, GoRouterState state) {
        return const LandlordDashboardScreen();
      },
    ),
    GoRoute(
      path: AppRoutes.createListing,
      builder: (BuildContext context, GoRouterState state) {
        return const CreateListingScreen();
      },
    ),
  ],
);
