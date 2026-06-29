class CreateListingData {
  const CreateListingData({
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

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'square_feet': squareFeet,
      'property_type': propertyType,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'landlord_phone': landlordPhone,
    };
  }
}
