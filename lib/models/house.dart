import 'package:flutter/foundation.dart';

/// Represents a rental property listing in the application.
///
/// This model mirrors the backend [HouseResponse] while remaining
/// independent of the serialization layer. It supports full JSON
/// serialization and deserialization, as well as value-based equality
/// and cloning via [copyWith].
///
/// Example usage:
/// ```dart
/// final house = House.fromJson(jsonResponse);
/// final json = house.toJson();
/// ```
@immutable
class House {
  /// Unique identifier for the house listing.
  final int id;

  /// Short, descriptive title of the rental property.
  final String title;

  /// Detailed description of the property and its amenities.
  final String? description;

  /// Monthly rental price in the local currency (FCFA).
  final double price;

  /// Number of bedrooms, if specified.
  final int? bedrooms;

  /// Number of bathrooms, if specified. May be fractional (e.g. 2.5).
  final double? bathrooms;

  /// Interior area in square metres, if specified.
  final int? squareFeet;

  /// Type of property (e.g. 'apartment', 'house', 'studio', 'hostel').
  final String? propertyType;

  /// URL of the primary image for the listing, if available.
  final String? imageUrl;

  /// URLs of every image for the listing, if available.
  final List<String> imageUrls;

  /// Neighborhood or quarter where the property is located.
  final String? neighborhood;

  /// Street address of the property.
  final String address;

  /// City where the property is located.
  final String city;

  /// State or region where the property is located, if applicable.
  final String? state;

  /// Postal or ZIP code, if applicable.
  final String? zipCode;

  /// Country where the property is located.
  final String? country;

  /// Geographic latitude, if available.
  final double? latitude;

  /// Geographic longitude, if available.
  final double? longitude;

  /// Availability status, such as `available` or `rented`.
  final String availabilityStatus;

  /// Phone number of the landlord or property manager.
  final String landlordPhone;

  /// UTC timestamp when the listing was created.
  final DateTime? createdAt;

  /// UTC timestamp when the listing was last updated.
  final DateTime? updatedAt;

  const House({
    required this.id,
    required this.title,
    this.description,
    required this.price,
    this.bedrooms,
    this.bathrooms,
    this.squareFeet,
    this.propertyType,
    this.imageUrl,
    this.imageUrls = const [],
    this.neighborhood,
    required this.address,
    required this.city,
    this.state,
    this.zipCode,
    this.country,
    this.latitude,
    this.longitude,
    this.availabilityStatus = 'available',
    required this.landlordPhone,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [House] instance from a JSON map (typically an API response).
  ///
  /// The JSON keys are expected to match the snake_case field names used
  /// by the backend (`square_feet`, `property_type`, `zip_code`,
  /// `landlord_phone`, `created_at`, `updated_at`).
  factory House.fromJson(Map<String, dynamic> json) {
    final imageUrl = json['image_url'] as String?;
    final hasGalleryImages =
        json.containsKey('image_urls') || json.containsKey('images');
    final galleryImages = _parseImageUrls(json);
    final availabilityStatus = _parseAvailabilityStatus(json);

    return House(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      bedrooms: json['bedrooms'] as int?,
      bathrooms: json['bathrooms'] != null
          ? (json['bathrooms'] as num).toDouble()
          : null,
      squareFeet: json['square_feet'] as int?,
      propertyType: json['property_type'] as String?,
      imageUrl: imageUrl,
      imageUrls: !hasGalleryImages &&
              galleryImages.isEmpty &&
              imageUrl != null &&
              imageUrl.isNotEmpty
          ? [imageUrl]
          : galleryImages,
      neighborhood: json['neighborhood'] as String?,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String?,
      zipCode: json['zip_code'] as String?,
      country: json['country'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      availabilityStatus: availabilityStatus,
      landlordPhone: json['landlord_phone'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this [House] instance into a JSON map.
  ///
  /// The produced map uses snake_case keys to match the backend contract.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'square_feet': squareFeet,
      'property_type': propertyType,
      'image_url': imageUrl,
      'image_urls': imageUrls,
      'neighborhood': neighborhood,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'availability_status': availabilityStatus,
      'landlord_phone': landlordPhone,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [House] with the given fields replaced by new
  /// values.
  House copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    int? bedrooms,
    double? bathrooms,
    int? squareFeet,
    String? propertyType,
    String? imageUrl,
    List<String>? imageUrls,
    String? neighborhood,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    double? latitude,
    double? longitude,
    String? availabilityStatus,
    String? landlordPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return House(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      squareFeet: squareFeet ?? this.squareFeet,
      propertyType: propertyType ?? this.propertyType,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      neighborhood: neighborhood ?? this.neighborhood,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      landlordPhone: landlordPhone ?? this.landlordPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is House &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          price == other.price &&
          bedrooms == other.bedrooms &&
          bathrooms == other.bathrooms &&
          squareFeet == other.squareFeet &&
          propertyType == other.propertyType &&
          imageUrl == other.imageUrl &&
          listEquals(imageUrls, other.imageUrls) &&
          neighborhood == other.neighborhood &&
          address == other.address &&
          city == other.city &&
          state == other.state &&
          zipCode == other.zipCode &&
          country == other.country &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          availabilityStatus == other.availabilityStatus &&
          landlordPhone == other.landlordPhone &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hashAll([
        id,
        title,
        description,
        price,
        bedrooms,
        bathrooms,
        squareFeet,
        propertyType,
        imageUrl,
        Object.hashAll(imageUrls),
        neighborhood,
        address,
        city,
        state,
        zipCode,
        country,
        latitude,
        longitude,
        availabilityStatus,
        landlordPhone,
        createdAt,
        updatedAt,
      ]);

  @override
  String toString() {
    return 'House(id: $id, title: $title, city: $city, price: $price)';
  }

  static List<String> _parseImageUrls(Map<String, dynamic> json) {
    final rawImages = json['image_urls'] ?? json['images'];
    if (rawImages is List) {
      return rawImages
          .whereType<String>()
          .where((image) => image.trim().isNotEmpty)
          .toList(growable: false);
    }

    return const [];
  }

  static String _parseAvailabilityStatus(Map<String, dynamic> json) {
    final explicitStatus =
        json['availability_status'] ?? json['status'] ?? json['listing_status'];
    if (explicitStatus is String && explicitStatus.trim().isNotEmpty) {
      return explicitStatus.trim().toLowerCase();
    }

    final isAvailable = json['is_available'] ?? json['available'];
    if (isAvailable is bool) {
      return isAvailable ? 'available' : 'rented';
    }

    return 'available';
  }
}
