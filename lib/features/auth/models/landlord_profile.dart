import 'landlord_registration_data.dart';

class LandlordProfile {
  const LandlordProfile({
    required this.id,
    required this.fullName,
    required this.verifiedPhoneNumber,
    required this.accountType,
    this.profilePhotoUrl,
  });

  final int id;
  final String fullName;
  final String verifiedPhoneNumber;
  final LandlordAccountType accountType;
  final String? profilePhotoUrl;

  factory LandlordProfile.fromJson(Map<String, dynamic> json) {
    return LandlordProfile(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      verifiedPhoneNumber: json['verified_phone_number'] as String,
      accountType: _accountTypeFromApiValue(json['account_type'] as String),
      profilePhotoUrl: json['profile_photo_url'] as String?,
    );
  }

  static LandlordAccountType _accountTypeFromApiValue(String value) {
    return switch (value) {
      'landlord' => LandlordAccountType.landlord,
      'property_agent' => LandlordAccountType.propertyAgent,
      _ => throw FormatException('Unknown landlord account type: $value'),
    };
  }
}
