import 'package:flutter/foundation.dart';

/// Represents a rental property listing in the application.
///
/// This model mirrors the backend [HouseResponse] while remaining
/// independent of the serialization layer.
@immutable
class House {
  final int id;
  final String title;
  final String? description;
  final double price;
  final int? bedrooms;
  final double? bathrooms;
  final int? squareFeet;
  final String? propertyType;
  final String address;
  final String city;
  final String? state;
  final String? zipCode;
  final String? country;
  final double? latitude;
  final double? longitude;
  final String landlordPhone;

  const House({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.bedrooms,
    this.bathrooms,
    this.squareFeet,
    this.propertyType,
    required this.address,
    required this.city,
    this.state,
    this.zipCode,
    this.country,
    this.latitude,
    this.longitude,
    required this.landlordPhone,
  });

  /// Creates a [House] from a JSON object (snake_case keys as returned by
  /// the backend API).
  factory House.fromJson(Map<String, dynamic> json) {
    return House(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      bedrooms: json['bedrooms'] as int?,
      bathrooms: (json['bathrooms'] as num?)?.toDouble(),
      squareFeet: json['square_feet'] as int?,
      propertyType: json['property_type'] as String?,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String?,
      zipCode: json['zip_code'] as String?,
      country: json['country'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      landlordPhone: json['landlord_phone'] as String,
    );
  }
}
