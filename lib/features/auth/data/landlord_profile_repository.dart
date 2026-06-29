import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../models/landlord_profile.dart';
import '../models/landlord_registration_data.dart';

class LandlordProfileRepository {
  LandlordProfileRepository({http.Client? client})
      : _client = client ?? ApiClient.client;

  final http.Client _client;

  Future<LandlordProfile> createProfile(
    LandlordRegistrationData registrationData,
  ) async {
    final response = await _client.post(
      Uri.parse('${ApiClient.baseUrl}/landlord-profiles'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': registrationData.fullName,
        'verified_phone_number': registrationData.phoneNumber,
        'account_type': registrationData.accountType.apiValue,
        'profile_photo_url': registrationData.profilePhotoUrl,
      }),
    );

    return _parseProfileResponse(response);
  }

  Future<LandlordProfile> getProfile(String phoneNumber) async {
    final uri = Uri.parse('${ApiClient.baseUrl}/landlord-profiles').replace(
      queryParameters: {'phone_number': phoneNumber},
    );
    final response = await _client.get(uri);

    return _parseProfileResponse(response);
  }

  LandlordProfile _parseProfileResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LandlordProfileException(
        body['message'] as String? ?? 'Unable to load landlord profile.',
      );
    }

    return LandlordProfile.fromJson(body['data'] as Map<String, dynamic>);
  }
}

class LandlordProfileException implements Exception {
  LandlordProfileException(this.message);

  final String message;

  @override
  String toString() => message;
}
