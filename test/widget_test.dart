import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/core/network/api_client.dart';
import 'package:house_finder/core/routing/app_router.dart';
import 'package:house_finder/core/routing/routes.dart';
import 'package:house_finder/main.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  setUp(() {
    appRouter.go(AppRoutes.home);
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
                    'Spacious apartment with modern finishes, secure parking, and 24/7 water supply. Located in the upscale Bastos neighborhood, close to embassies and international schools.',
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
                    'Compact studio ideal for students. Shared kitchen and bathroom. Walking distance to campus and affordable restaurants.',
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
              {
                'id': 3,
                'title': 'Family House in Bonapriso',
                'description':
                    'Beautiful family home with a small garden, tiled floors, and independent water tank. Quiet street with friendly neighbors.',
                'price': 380000,
                'bedrooms': 4,
                'bathrooms': 2.5,
                'square_feet': 200,
                'property_type': 'house',
                'address': 'Avenue de Gaulle, Bonapriso',
                'city': 'Douala',
                'state': 'Littoral',
                'zip_code': '23456',
                'country': 'Cameroon',
                'latitude': 4.0500,
                'longitude': 9.7000,
                'landlord_phone': '+237676345678',
              },
              {
                'id': 4,
                'title': 'Furnished 2-Bedroom Flat in Akwa',
                'description':
                    'Fully furnished flat in the commercial heart of Douala. Close to banks, supermarkets, and public transport. Air conditioning in both bedrooms.',
                'price': 250000,
                'bedrooms': 2,
                'bathrooms': 2,
                'square_feet': 90,
                'property_type': 'apartment',
                'address': 'Boulevard de la Liberté, Akwa',
                'city': 'Douala',
                'state': 'Littoral',
                'zip_code': '23457',
                'country': 'Cameroon',
                'latitude': 4.0430,
                'longitude': 9.6940,
                'landlord_phone': '+237677456789',
              },
              {
                'id': 5,
                'title': 'Cozy 1-Bedroom in Buea Town',
                'description':
                    'Clean one-bedroom apartment with uninterrupted mountain views. Reliable electricity and good internet coverage. Ideal for young professionals.',
                'price': 120000,
                'bedrooms': 1,
                'bathrooms': 1,
                'square_feet': 55,
                'property_type': 'apartment',
                'address': 'Great Soppo, Buea Town',
                'city': 'Buea',
                'state': 'Southwest',
                'zip_code': '34567',
                'country': 'Cameroon',
                'latitude': 4.1520,
                'longitude': 9.2900,
                'landlord_phone': '+237678567890',
              },
            ],
          }),
          200,
        );
      }
      return http.Response('Not Found', 404);
    });
  });

  tearDown(() {
    ApiClient.client.close();
    ApiClient.client = http.Client();
  });

  testWidgets('App launches and shows header and search field',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HouseFinderApp());
    await tester.pump(); // First frame

    expect(find.text('House Finder'), findsOneWidget);
    expect(find.text('Find your perfect home'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Advance past the async loading
    await tester.pumpAndSettle();

    // Houses should be visible after loading
    expect(find.byType(Card), findsWidgets);
  });

  testWidgets('Search filters the house list', (WidgetTester tester) async {
    await tester.pumpWidget(const HouseFinderApp());
    await tester.pumpAndSettle();

    // Verify all houses are shown initially
    expect(find.byType(Card), findsWidgets);

    // Enter a search query that matches only some listings
    await tester.enterText(find.byType(TextField), 'Yaoundé');
    await tester.pumpAndSettle();

    // Filtered results should still show cards (Yaoundé houses)
    expect(find.byType(Card), findsWidgets);

    // Enter a query that matches nothing
    await tester.enterText(find.byType(TextField), 'xyzabc123');
    await tester.pumpAndSettle();

    // Empty state should be shown
    expect(find.text('No houses found'), findsOneWidget);
    expect(find.text('Try adjusting your search criteria'), findsOneWidget);
  });

  testWidgets('Navigation to House Details works',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HouseFinderApp());
    await tester.pumpAndSettle();

    // Tap the first house card
    await tester.tap(find.byType(Card).first);
    await tester.pumpAndSettle();

    expect(find.text('House Details'), findsOneWidget);
    expect(find.text('House #1'), findsOneWidget);
  });

  testWidgets('Displays error state when API fails',
      (WidgetTester tester) async {
    ApiClient.client = MockClient((request) async {
      return http.Response('Internal Server Error', 500);
    });

    await tester.pumpWidget(const HouseFinderApp());
    // Let the async API call and entrance animations complete
    await tester.pump();
    await tester.pumpAndSettle();

    // No cards should be shown when the API fails
    expect(find.byType(Card), findsNothing);
    // Error state should be visible
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(
      find.text('Failed to load houses. Please check your connection and try again.'),
      findsWidgets,
    );
    // Retry button should be present
    expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
  });
}
