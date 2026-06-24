import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/screens/home_screen.dart';
import '../../models/house.dart';
import 'routes.dart';
import '../../features/house_details/screens/house_details_screen.dart';

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
        final String houseId = state.pathParameters['id'] ?? '';
        final House? house = state.extra as House?;
        return HouseDetailsScreen(houseId: houseId, house: house);
      },
    ),
  ],
);