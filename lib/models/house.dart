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
}
