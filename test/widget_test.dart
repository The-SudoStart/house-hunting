import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/core/network/api_client.dart';
import 'package:house_finder/core/routing/app_router.dart';
import 'package:house_finder/core/routing/routes.dart';
import 'package:house_finder/main.dart';
import 'package:house_finder/models/house.dart';
import 'package:house_finder/services/house_service.dart';
import 'package:house_finder/services/location_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeHouseService extends HouseService {
  final List<House> _houses;

  _FakeHouseService(this._houses);

  @override
  Future<List<House>> getCachedHouses() async {
    return const [];
  }

  @override
  Future<List<House>> getHouses() async {
    return _houses;
  }
}

class _FakeLocationService extends LocationService {
  @override
  Future<UserLocation> requestCurrentLocation() async {
    return const UserLocation(latitude: 3.8480, longitude: 11.5021);
  }
}

void main() {
  final locationService = _FakeLocationService();
  final sampleHouses = [
    const House(
      id: 1,
      title: 'Modern 3-Bedroom Apartment in Bastos',
      description:
          'Spacious apartment with modern finishes, secure parking, and 24/7 water supply.',
      price: 450000,
      bedrooms: 3,
      bathrooms: 2,
      squareFeet: 140,
      propertyType: 'apartment',
      address: 'Rue 1.123, Bastos',
      city: 'Yaoundé',
      state: 'Centre',
      zipCode: '12345',
      country: 'Cameroon',
      latitude: 3.8480,
      longitude: 11.5021,
      landlordPhone: '+237674123456',
    ),
    const House(
      id: 2,
      title: 'Affordable Studio near University of Yaoundé I',
      description: 'Compact studio ideal for students.',
      price: 75000,
      bedrooms: 1,
      bathrooms: 1,
      squareFeet: 35,
      propertyType: 'studio',
      address: 'Ngoa-Ekelle, Campus Road',
      city: 'Yaoundé',
      state: 'Centre',
      zipCode: '12346',
      country: 'Cameroon',
      latitude: 3.8600,
      longitude: 11.5100,
      landlordPhone: '+237675234567',
    ),
  ];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appRouter.go(AppRoutes.entry);
  });

  tearDown(() {
    ApiClient.client.close();
    ApiClient.client = http.Client();
  });

  testWidgets('App launches with entry actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      HouseFinderApp(
        houseService: _FakeHouseService(sampleHouses),
        locationService: locationService,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Find House'), findsOneWidget);
    expect(find.text('List a House'), findsOneWidget);
  });

  testWidgets('Find House opens listings home', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      HouseFinderApp(
        houseService: _FakeHouseService(sampleHouses),
        locationService: locationService,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Find House'));
    await tester.pump();

    expect(find.text('House Finder'), findsOneWidget);
    expect(
      find.text('Find available homes by neighborhood, budget, and type.'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsOneWidget);

    final listingFinder = find.text('Modern 3-Bedroom Apartment in Bastos');
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (listingFinder.evaluate().isNotEmpty) {
        break;
      }
    }

    expect(listingFinder, findsOneWidget);
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

    await tester.tap(find.widgetWithText(FilledButton, 'Find House'));
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsWidgets);

    await tester.enterText(find.byType(TextField), 'Bastos');
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsWidgets);

    await tester.enterText(find.byType(TextField), 'xyzabc123');
    await tester.pumpAndSettle();

    expect(find.text('No results found'), findsOneWidget);
    expect(find.text('Try adjusting your search or filters'), findsOneWidget);
  });

  testWidgets('Displays error state when API fails', (
    WidgetTester tester,
  ) async {
    ApiClient.client = MockClient((request) async {
      return http.Response('Internal Server Error', 500);
    });

    await tester.pumpWidget(HouseFinderApp(locationService: locationService));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Find House'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsNothing);
    expect(find.text('Something went wrong'), findsOneWidget);
    expect(
      find.text(
        'The listings service is unavailable right now. Please try again soon.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
  });
}
