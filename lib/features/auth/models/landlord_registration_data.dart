enum LandlordAccountType {
  landlord,
  propertyAgent;

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
  });

  final String fullName;
  final String phoneNumber;
  final LandlordAccountType accountType;
}
