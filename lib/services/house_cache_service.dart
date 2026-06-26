import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/house.dart';

class CachedHouseListings {
  final List<House> houses;
  final DateTime cachedAt;
  final bool isExpired;

  const CachedHouseListings({
    required this.houses,
    required this.cachedAt,
    required this.isExpired,
  });
}

class HouseCacheService {
  static const _housesKey = 'cached_houses';
  static const _cachedAtKey = 'cached_houses_at';
  static const _maxAge = Duration(hours: 24);

  Future<void> saveHouses(List<House> houses) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(
      houses.map((house) => house.toJson()).toList(growable: false),
    );

    await prefs.setString(_housesKey, payload);
    await prefs.setString(_cachedAtKey, DateTime.now().toIso8601String());
  }

  Future<CachedHouseListings?> loadHouses() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = prefs.getString(_housesKey);
    final cachedAtValue = prefs.getString(_cachedAtKey);

    if (payload == null || cachedAtValue == null) return null;

    final cachedAt = DateTime.tryParse(cachedAtValue);
    if (cachedAt == null) return null;

    final decoded = jsonDecode(payload);
    if (decoded is! List) return null;

    final houses = decoded
        .whereType<Map<String, dynamic>>()
        .map(House.fromJson)
        .toList(growable: false);

    return CachedHouseListings(
      houses: houses,
      cachedAt: cachedAt,
      isExpired: DateTime.now().difference(cachedAt) > _maxAge,
    );
  }
}
