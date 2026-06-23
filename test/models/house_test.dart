import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/models/house.dart';

void main() {
  group('House.fromJson', () {
    test('parses a complete API response with all fields', () {
      final json = <String, dynamic>{
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
        'created_at': '2024-06-01T12:00:00Z',
        'updated_at': '2024-06-15T08:30:00Z',
      };

      final house = House.fromJson(json);

      expect(house.id, 1);
      expect(house.title, 'Modern 3-Bedroom Apartment in Bastos');
      expect(house.description, 'Spacious apartment with modern finishes.');
      expect(house.price, 450000.0);
      expect(house.bedrooms, 3);
      expect(house.bathrooms, 2.0);
      expect(house.squareFeet, 140);
      expect(house.propertyType, 'apartment');
      expect(house.address, 'Rue 1.123, Bastos');
      expect(house.city, 'Yaoundé');
      expect(house.state, 'Centre');
      expect(house.zipCode, '12345');
      expect(house.country, 'Cameroon');
      expect(house.latitude, 3.8480);
      expect(house.longitude, 11.5021);
      expect(house.landlordPhone, '+237674123456');
      expect(house.createdAt, DateTime.parse('2024-06-01T12:00:00Z'));
      expect(house.updatedAt, DateTime.parse('2024-06-15T08:30:00Z'));
    });

    test('parses a minimal API response with optional fields omitted', () {
      final json = <String, dynamic>{
        'id': 2,
        'title': 'Affordable Studio',
        'price': 75000,
        'address': 'Ngoa-Ekelle, Campus Road',
        'city': 'Yaoundé',
        'landlord_phone': '+237675234567',
      };

      final house = House.fromJson(json);

      expect(house.id, 2);
      expect(house.title, 'Affordable Studio');
      expect(house.description, isNull);
      expect(house.price, 75000.0);
      expect(house.bedrooms, isNull);
      expect(house.bathrooms, isNull);
      expect(house.squareFeet, isNull);
      expect(house.propertyType, isNull);
      expect(house.state, isNull);
      expect(house.zipCode, isNull);
      expect(house.country, isNull);
      expect(house.latitude, isNull);
      expect(house.longitude, isNull);
      expect(house.createdAt, isNull);
      expect(house.updatedAt, isNull);
    });

    test('parses fractional bathrooms correctly', () {
      final json = <String, dynamic>{
        'id': 3,
        'title': 'Family House',
        'price': 380000,
        'address': 'Avenue de Gaulle',
        'city': 'Douala',
        'landlord_phone': '+237676345678',
        'bathrooms': 2.5,
      };

      final house = House.fromJson(json);
      expect(house.bathrooms, 2.5);
    });
  });

  group('House.toJson', () {
    test('serializes all fields to snake_case keys', () {
      final house = House(
        id: 1,
        title: 'Modern 3-Bedroom Apartment in Bastos',
        description: 'Spacious apartment with modern finishes.',
        price: 450000,
        bedrooms: 3,
        bathrooms: 2.0,
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
        createdAt: DateTime.parse('2024-06-01T12:00:00Z'),
        updatedAt: DateTime.parse('2024-06-15T08:30:00Z'),
      );

      final json = house.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Modern 3-Bedroom Apartment in Bastos');
      expect(json['description'], 'Spacious apartment with modern finishes.');
      expect(json['price'], 450000.0);
      expect(json['bedrooms'], 3);
      expect(json['bathrooms'], 2.0);
      expect(json['square_feet'], 140);
      expect(json['property_type'], 'apartment');
      expect(json['address'], 'Rue 1.123, Bastos');
      expect(json['city'], 'Yaoundé');
      expect(json['state'], 'Centre');
      expect(json['zip_code'], '12345');
      expect(json['country'], 'Cameroon');
      expect(json['latitude'], 3.8480);
      expect(json['longitude'], 11.5021);
      expect(json['landlord_phone'], '+237674123456');
      expect(json['created_at'], '2024-06-01T12:00:00.000Z');
      expect(json['updated_at'], '2024-06-15T08:30:00.000Z');
    });

    test('serializes null optional fields as null', () {
      final house = House(
        id: 2,
        title: 'Affordable Studio',
        price: 75000,
        address: 'Ngoa-Ekelle, Campus Road',
        city: 'Yaoundé',
        landlordPhone: '+237675234567',
      );

      final json = house.toJson();

      expect(json['description'], isNull);
      expect(json['bedrooms'], isNull);
      expect(json['bathrooms'], isNull);
      expect(json['square_feet'], isNull);
      expect(json['property_type'], isNull);
      expect(json['state'], isNull);
      expect(json['zip_code'], isNull);
      expect(json['country'], isNull);
      expect(json['latitude'], isNull);
      expect(json['longitude'], isNull);
      expect(json['created_at'], isNull);
      expect(json['updated_at'], isNull);
    });
  });

  group('House round-trip', () {
    test('toJson -> fromJson produces an equivalent House', () {
      final original = House(
        id: 5,
        title: 'Cozy 1-Bedroom in Buea Town',
        description: 'Clean one-bedroom apartment with uninterrupted mountain views.',
        price: 120000,
        bedrooms: 1,
        bathrooms: 1.0,
        squareFeet: 55,
        propertyType: 'apartment',
        address: 'Great Soppo, Buea Town',
        city: 'Buea',
        state: 'Southwest',
        zipCode: '34567',
        country: 'Cameroon',
        latitude: 4.1520,
        longitude: 9.2900,
        landlordPhone: '+237678567890',
        createdAt: DateTime.parse('2024-01-10T10:00:00Z'),
        updatedAt: DateTime.parse('2024-02-20T14:00:00Z'),
      );

      final json = original.toJson();
      final restored = House.fromJson(json);

      expect(restored, original);
      expect(restored.hashCode, original.hashCode);
    });
  });

  group('House.copyWith', () {
    test('returns a new instance with updated fields', () {
      final house = House(
        id: 1,
        title: 'Old Title',
        price: 100000,
        address: 'Old Address',
        city: 'Yaoundé',
        landlordPhone: '+237000000000',
      );

      final updated = house.copyWith(
        title: 'New Title',
        price: 200000,
      );

      expect(updated.id, 1);
      expect(updated.title, 'New Title');
      expect(updated.price, 200000.0);
      expect(updated.address, 'Old Address');
      expect(updated.city, 'Yaoundé');
    });

    test('preserves original values when no arguments are provided', () {
      final house = House(
        id: 1,
        title: 'Title',
        price: 100000,
        address: 'Address',
        city: 'City',
        landlordPhone: '+237000000000',
      );

      final copy = house.copyWith();
      expect(copy, house);
    });
  });

  group('House equality', () {
    test('equal instances have the same hashCode', () {
      final a = House(
        id: 1,
        title: 'Title',
        price: 100000,
        address: 'Address',
        city: 'City',
        landlordPhone: '+237000000000',
      );
      final b = House(
        id: 1,
        title: 'Title',
        price: 100000,
        address: 'Address',
        city: 'City',
        landlordPhone: '+237000000000',
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('different instances are not equal', () {
      final a = House(
        id: 1,
        title: 'Title A',
        price: 100000,
        address: 'Address',
        city: 'City',
        landlordPhone: '+237000000000',
      );
      final b = House(
        id: 1,
        title: 'Title B',
        price: 100000,
        address: 'Address',
        city: 'City',
        landlordPhone: '+237000000000',
      );

      expect(a, isNot(b));
    });
  });
}
