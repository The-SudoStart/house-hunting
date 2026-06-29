import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/core/network/api_client.dart';
import 'package:house_finder/data/repositories/house_repository.dart';
import 'package:house_finder/features/landlord/models/create_listing_data.dart';
import 'package:house_finder/models/house.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HouseRepository.getAllHouses', () {
    late HouseRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = HouseRepository();
    });

    tearDown(() {
      ApiClient.client.close();
      ApiClient.client = http.Client();
    });

    test('returns a list of House models on a successful 200 response',
        () async {
      ApiClient.client = MockClient((request) async {
        expect(request.url.path, '/houses');
        return http.Response(
          jsonEncode({
            'status': 'success',
            'data': [
              {
                'id': 1,
                'title': 'Modern 3-Bedroom Apartment in Bastos',
                'description': 'Spacious apartment with modern finishes.',
                'price': 450000,
                'bedrooms': 3,
                'bathrooms': 2.0,
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
                'title': 'Affordable Studio',
                'price': 75000,
                'address': 'Ngoa-Ekelle, Campus Road',
                'city': 'Yaoundé',
                'landlord_phone': '+237675234567',
              },
            ],
          }),
          200,
        );
      });

      final houses = await repository.getAllHouses();

      expect(houses, isA<List<House>>());
      expect(houses.length, 2);
      expect(houses[0].id, 1);
      expect(houses[0].title, 'Modern 3-Bedroom Apartment in Bastos');
      expect(houses[0].price, 450000.0);
      expect(houses[1].id, 2);
      expect(houses[1].title, 'Affordable Studio');
    });

    test('returns an empty list when the data field is empty', () async {
      ApiClient.client = MockClient((request) async {
        return http.Response(
          jsonEncode({'status': 'success', 'data': []}),
          200,
        );
      });

      final houses = await repository.getAllHouses();

      expect(houses, isEmpty);
    });

    test('returns an empty list when the data field is missing', () async {
      ApiClient.client = MockClient((request) async {
        return http.Response(
          jsonEncode({'status': 'success'}),
          200,
        );
      });

      final houses = await repository.getAllHouses();

      expect(houses, isEmpty);
    });

    test('throws an exception on a 500 server error', () async {
      ApiClient.client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      expect(
        repository.getAllHouses(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('The server could not load listings right now.'),
          ),
        ),
      );
    });

    test('throws an exception on a 404 not found', () async {
      ApiClient.client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      expect(
        repository.getAllHouses(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('The server could not load listings right now.'),
          ),
        ),
      );
    });

    test('throws an exception on malformed JSON', () async {
      ApiClient.client = MockClient((request) async {
        return http.Response('not valid json', 200);
      });

      expect(
        repository.getAllHouses(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('HouseRepository.createHouse', () {
    late HouseRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = HouseRepository();
    });

    tearDown(() {
      ApiClient.client.close();
      ApiClient.client = http.Client();
    });

    test('submits a listing and returns a pending review house', () async {
      ApiClient.client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/houses');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['title'], 'Two Bedroom Apartment');
        expect(body['price'], 180000.0);
        expect(body['address'], 'Melen Road');
        expect(body['city'], 'Yaoundé');
        expect(body['landlord_phone'], '+237674123456');

        return http.Response(
          jsonEncode({
            'status': 'success',
            'data': {
              'id': 9,
              'title': 'Two Bedroom Apartment',
              'description': 'Near the main road.',
              'price': 180000,
              'bedrooms': 2,
              'bathrooms': 1.0,
              'square_feet': 80,
              'property_type': 'apartment',
              'address': 'Melen Road',
              'city': 'Yaoundé',
              'country': 'Cameroon',
              'availability_status': 'pending_review',
              'landlord_phone': '+237674123456',
            },
          }),
          201,
        );
      });

      final house = await repository.createHouse(
        const CreateListingData(
          title: 'Two Bedroom Apartment',
          description: 'Near the main road.',
          price: 180000,
          bedrooms: 2,
          bathrooms: 1,
          squareFeet: 80,
          propertyType: 'apartment',
          address: 'Melen Road',
          city: 'Yaoundé',
          country: 'Cameroon',
          landlordPhone: '+237674123456',
        ),
      );

      expect(house.id, 9);
      expect(house.availabilityStatus, 'pending_review');
    });

    test('throws a repository exception when submission fails', () async {
      ApiClient.client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      expect(
        repository.createHouse(
          const CreateListingData(
            title: 'Two Bedroom Apartment',
            price: 180000,
            address: 'Melen Road',
            city: 'Yaoundé',
            landlordPhone: '+237674123456',
          ),
        ),
        throwsA(isA<HouseRepositoryException>()),
      );
    });
  });
}
