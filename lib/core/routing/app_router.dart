import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../features/house_details/screens/house_details_screen.dart';
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
  ],
);
