import 'dart:convert';
import 'dart:developer';

import '../../core/network/api_client.dart';
import '../../models/house.dart';

/// Repository responsible for retrieving house data from the backend.
///
/// This class abstracts all networking logic from the UI and service layers,
/// handling HTTP communication, JSON parsing, and basic error translation.
/// Consumers receive fully typed [House] models or receive a descriptive
/// exception when the call fails.
class HouseRepository {
  /// Fetches every house listing from the `/houses` endpoint.
  ///
  /// Returns a list of [House] instances parsed from the API response.
  /// Throws an [Exception] when the server responds with a non-2xx status
  /// code or when the response body cannot be decoded.
  Future<List<House>> getAllHouses() async {
    final response = await ApiClient.client
        .get(Uri.parse('${ApiClient.baseUrl}/houses'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = (body['data'] as List<dynamic>?) ?? [];
      return data
          .map((e) => House.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      log('API error: ${response.statusCode} ${response.body}');
      throw Exception(
        'Failed to load houses (status ${response.statusCode})',
      );
    }
  }
}
