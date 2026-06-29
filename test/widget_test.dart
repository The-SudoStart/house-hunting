import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/core/network/api_client.dart';
import 'package:house_finder/core/routing/app_router.dart';
import 'package:house_finder/core/routing/routes.dart';
import 'package:house_finder/main.dart';
import 'package:house_finder/services/location_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _FakeLocationService extends LocationService {
  @override
  Future<UserLocation> requestCurrentLocation() async {
    return const UserLocation(latitude: 3.8480, longitude: 11.5021);
  }
}

void main() {
  final locationService = _FakeLocationService();

  setUp(() {
    appRouter.go(AppRoutes.home);
  });

  tearDown(() {
    ApiClient.client.close();
    ApiClient.client = http.Client();
  });

  testWidgets('App launches and shows header and search field', (
    WidgetTester tester,
  ) async {
    ApiClient.client = MockClient((request) async {
      if (request.url.path == '/houses') {
        return http.Response(
          jsonEncode({
            'status': 'success',
            'data': [
              {
                'id': 1,
                'title': 'Modern 3-Bedroom Apartment in Bastos',
                'description':
                    'Spacious apartment with modern finishes, secure parking, and 24/7 water supply.',
                'price': 450000,
                'bedrooms': 3,
                'bathrooms': 2,
                'square_feet': 140,
                'property_type': 'apartment',
                'address': 'Rue 1.123, Bastos',
                'city': 'Yaoundé',
                'state': 'Centre',
                'zip_code': '12345',
                'country': 'Cameroon',
                'latitude': 3.8480,
                'longitude': 11.5021,
                'landlord_phone': '+237674123456',
              },
              {
                'id': 2,
                'title': 'Affordable Studio near University of Yaoundé I',
                'description':
                    'Compact studio ideal for students. Shared kitchen and bathroom.',
                'price': 75000,
                'bedrooms': 1,
                'bathrooms': 1,
                'square_feet': 35,
                'property_type': 'studio',
                'address': 'Ngoa-Ekelle, Campus Road',
                'city': 'Yaoundé',
                'state': 'Centre',
                'zip_code': '12346',
                'country': 'Cameroon',
                'latitude': 3.8600,
                'longitude': 11.5100,
                'landlord_phone': '+237675234567',
              },
            ],
          }),
          200,
        );
      }
      return http.Response('Not Found', 404);
    });

    await tester.pumpWidget(HouseFinderApp(locationService: locationService));
    await tester.pump();

    expect(find.text('House Finder'), findsOneWidget);
    expect(find.text('Find your perfect home'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(Card), findsWidgets);
  });

  testWidgets('Search filters the house list', (WidgetTester tester) async {
    ApiClient.client = MockClient((request) async {
      if (request.url.path == '/houses') {
        return http.Response(
          jsonEncode({
            'status': 'success',
            'data': [
              {
                'id': 1,
                'title': 'Modern Apartment in Bastos',
                'price': 450000,
                'address': 'Rue 1.123, Bastos',
                'city': 'Yaoundé',
                'landlord_phone': '+237674123456',
              },
              {
                'id': 2,
                'title': 'Studio near University',
                'price': 75000,
                'address': 'Campus Road',
                'city': 'Yaoundé',
                'landlord_phone': '+237675234567',
              },
            ],
          }),
          200,
        );
      }
      return http.Response('Not Found', 404);
    });

    await tester.pumpWidget(HouseFinderApp(locationService: locationService));
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsWidgets);

    await tester.enterText(find.byType(TextField), 'Bastos');
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsWidgets);

    await tester.enterText(find.byType(TextField), 'xyzabc123');
    await tester.pumpAndSettle();

    expect(find.text('No houses found'), findsOneWidget);
    expect(find.text('Try adjusting your search criteria'), findsOneWidget);
  });

  testWidgets('Displays error state when API fails', (
    WidgetTester tester,
  ) async {
    ApiClient.client = MockClient((request) async {
      return http.Response('Internal Server Error', 500);
    });

    await tester.pumpWidget(HouseFinderApp(locationService: locationService));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsNothing);
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(
      find.text(
        'Failed to load houses. Please check your connection and try again.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
  });
}
