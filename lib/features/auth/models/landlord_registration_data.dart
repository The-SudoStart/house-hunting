enum LandlordAccountType {
  landlord,
  propertyAgent;

  String get apiValue {
    return switch (this) {
      LandlordAccountType.landlord => 'landlord',
      LandlordAccountType.propertyAgent => 'property_agent',
    };
  }

  String get label {
    return switch (this) {
      LandlordAccountType.landlord => 'Landlord',
      LandlordAccountType.propertyAgent => 'Property Agent',
    };
  }
}

class LandlordRegistrationData {
  const LandlordRegistrationData({
    required this.fullName,
    required this.phoneNumber,
    required this.accountType,
    this.profilePhotoUrl,
  });

  final String fullName;
  final String phoneNumber;
  final LandlordAccountType accountType;
  final String? profilePhotoUrl;
}
