import 'dart:convert';
import 'dart:developer';

import '../core/network/api_client.dart';
import '../models/house.dart';

/// Provides house listing data for the application.
///
/// Fetches listings from the backend API via [ApiClient]. Errors are
/// propagated to the caller so the UI can handle them gracefully.
class HouseService {
  /// Fetch all house listings from the backend API.
  static Future<List<House>> getHouses() async {
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
