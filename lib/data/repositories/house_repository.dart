import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../../core/network/api_client.dart';
import '../../models/house.dart';
import '../../services/house_cache_service.dart';

enum HouseRepositoryErrorType {
  network,
  server,
  timeout,
  parsing,
  unknown,
}

class HouseRepositoryException implements Exception {
  final HouseRepositoryErrorType type;
  final String message;

  const HouseRepositoryException(this.type, this.message);

  @override
  String toString() => message;
}

/// Repository responsible for retrieving house data from the backend.
///
/// This class abstracts all networking logic from the UI and service layers,
/// handling HTTP communication, JSON parsing, and basic error translation.
/// Consumers receive fully typed [House] models or receive a descriptive
/// exception when the call fails.
class HouseRepository {
  final HouseCacheService _cacheService;

  HouseRepository({HouseCacheService? cacheService})
      : _cacheService = cacheService ?? HouseCacheService();

  /// Fetches every house listing from the `/houses` endpoint.
  ///
  /// Returns a list of [House] instances parsed from the API response.
  /// Throws an [Exception] when the server responds with a non-2xx status
  /// code or when the response body cannot be decoded.
  Future<List<House>> getAllHouses() async {
    try {
      final response = await ApiClient.client
          .get(Uri.parse('${ApiClient.baseUrl}/houses'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = (body['data'] as List<dynamic>?) ?? [];
        final houses = data
            .map((e) => House.fromJson(e as Map<String, dynamic>))
            .toList(growable: false);

        await _cacheService.saveHouses(houses);
        return houses;
      }

      log('API error: ${response.statusCode} ${response.body}');
      return await _loadCacheOrThrow(
        HouseRepositoryException(
          HouseRepositoryErrorType.server,
          'The server could not load listings right now.',
        ),
      );
    } on TimeoutException {
      return _loadCacheOrThrow(
        const HouseRepositoryException(
          HouseRepositoryErrorType.timeout,
          'The request timed out. Please try again.',
        ),
      );
    } on FormatException {
      return _loadCacheOrThrow(
        const HouseRepositoryException(
          HouseRepositoryErrorType.parsing,
          'Listings could not be read correctly.',
        ),
      );
    } on http.ClientException {
      return _loadCacheOrThrow(
        const HouseRepositoryException(
          HouseRepositoryErrorType.network,
          'You appear to be offline. Check your connection and try again.',
        ),
      );
    } on HouseRepositoryException {
      rethrow;
    } catch (e) {
      log('Unexpected listings error: $e');
      return _loadCacheOrThrow(
        const HouseRepositoryException(
          HouseRepositoryErrorType.unknown,
          'Something went wrong while loading listings.',
        ),
      );
    }
  }

  Future<List<House>> loadCachedHouses() async {
    final cached = await _cacheService.loadHouses();
    return cached?.houses ?? const [];
  }

  Future<List<House>> _loadCacheOrThrow(
    HouseRepositoryException exception,
  ) async {
    final cached = await _cacheService.loadHouses();
    if (cached != null && cached.houses.isNotEmpty) {
      return cached.houses;
    }

    throw exception;
  }
}
