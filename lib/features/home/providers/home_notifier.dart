import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/house.dart';
import '../../../services/house_service.dart';
import '../../../services/location_service.dart';
import 'home_state.dart';

class HomeFilters {
  final RangeValues? priceRange;
  final String? propertyType;
  final int? bedrooms;

  const HomeFilters({
    this.priceRange,
    this.propertyType,
    this.bedrooms,
  });

  bool get hasActiveFilters =>
      priceRange != null || propertyType != null || bedrooms != null;

  HomeFilters copyWith({
    RangeValues? priceRange,
    String? propertyType,
    int? bedrooms,
    bool clearPriceRange = false,
    bool clearPropertyType = false,
    bool clearBedrooms = false,
  }) {
    return HomeFilters(
      priceRange: clearPriceRange ? null : priceRange ?? this.priceRange,
      propertyType:
          clearPropertyType ? null : propertyType ?? this.propertyType,
      bedrooms: clearBedrooms ? null : bedrooms ?? this.bedrooms,
    );
  }
}

class HomeNotifier extends ChangeNotifier {
  final HouseService _houseService;
  final LocationService _locationService;

  HomeState _state = const HomeInitial();
  List<House> _allHouses = [];
  UserLocation? _userLocation;
  String? _locationMessage;
  String? _listMessage;
  final Map<int, double> _distancesByHouseId = {};

  HomeNotifier(
    this._houseService, {
    LocationService? locationService,
  }) : _locationService = locationService ?? LocationService();

  HomeState get state => _state;

  List<House> get allHouses => _allHouses;

  UserLocation? get userLocation => _userLocation;

  String? get locationMessage => _locationMessage;

  String? get listMessage => _listMessage;

  double get minHousePrice {
    if (_allHouses.isEmpty) return 0;
    return _allHouses
        .map((house) => house.price)
        .reduce((value, element) => value < element ? value : element);
  }

  double get maxHousePrice {
    if (_allHouses.isEmpty) return 0;
    return _allHouses
        .map((house) => house.price)
        .reduce((value, element) => value > element ? value : element);
  }

  List<String> get propertyTypes {
    final types = _allHouses
        .map((house) => house.propertyType?.trim())
        .whereType<String>()
        .where((type) => type.isNotEmpty)
        .toSet()
        .toList();
    types.sort();
    return types;
  }

  List<int> get bedroomCounts {
    final counts = _allHouses
        .map((house) => house.bedrooms)
        .whereType<int>()
        .toSet()
        .toList();
    counts.sort();
    return counts;
  }

  double? distanceForHouse(House house) => _distancesByHouseId[house.id];

  House? houseById(int id) {
    for (final house in _allHouses) {
      if (house.id == id) return house;
    }
    return null;
  }

  List<House> filteredHouses(
    String query, [
    HomeFilters filters = const HomeFilters(),
  ]) {
    final searchLower = query.trim().toLowerCase();
    return _allHouses.where((house) {
      final matchesSearch = searchLower.isEmpty ||
          _matchesText(house.title, searchLower) ||
          _matchesText(house.neighborhood, searchLower) ||
          _matchesText(house.address, searchLower) ||
          _matchesText(house.city, searchLower) ||
          _matchesText(house.state, searchLower);

      final priceRange = filters.priceRange;
      final matchesPrice = priceRange == null ||
          (house.price >= priceRange.start && house.price <= priceRange.end);

      final propertyType = filters.propertyType;
      final matchesType = propertyType == null ||
          propertyType.isEmpty ||
          house.propertyType?.toLowerCase() == propertyType.toLowerCase();

      final bedrooms = filters.bedrooms;
      final matchesBedrooms = bedrooms == null || house.bedrooms == bedrooms;

      return matchesSearch && matchesPrice && matchesType && matchesBedrooms;
    }).toList(growable: false);
  }

  Future<void> loadHouses() async {
    _state = const HomeLoading();
    notifyListeners();

    try {
      final cachedHouses = await _houseService.getCachedHouses();
      if (cachedHouses.isNotEmpty) {
        _applyHouses(cachedHouses);
        _state = HomeSuccess(
          _allHouses,
          notice: 'Showing saved listings while checking for updates.',
        );
        notifyListeners();
      }

      final houses = await _houseService.getHouses();
      _applyHouses(houses);
      await _refreshLocation(notifyWhenDone: false);
      _listMessage = null;
      _state = HomeSuccess(_allHouses);
      notifyListeners();
    } catch (e) {
      _state = HomeError(_friendlyErrorMessage(e));
      notifyListeners();
    }
  }

  Future<void> refreshHouses() async {
    try {
      final houses = await _houseService.getHouses();
      _applyHouses(houses);
      _recalculateDistances();
      _sortHousesByDistance();
      _listMessage = null;
      _state = HomeSuccess(_allHouses);
      notifyListeners();
    } catch (e) {
      if (_allHouses.isNotEmpty) {
        _listMessage = _friendlyErrorMessage(e);
        _state = HomeSuccess(_allHouses, notice: _listMessage);
      } else {
        _state = HomeError(_friendlyErrorMessage(e));
      }
      notifyListeners();
    }
  }

  Future<void> retry() {
    return loadHouses();
  }

  Future<void> refreshLocation() async {
    await _refreshLocation(notifyWhenDone: true);
  }

  Future<void> _refreshLocation({required bool notifyWhenDone}) async {
    try {
      _userLocation = await _locationService.requestCurrentLocation();
      _locationMessage = null;
      _recalculateDistances();
      _sortHousesByDistance();
      if (_state is HomeSuccess) {
        _state = HomeSuccess(_allHouses);
      }
    } on LocationFailure catch (e) {
      _clearLocation();
      _locationMessage = switch (e.reason) {
        LocationFailureReason.serviceDisabled =>
          'Location services are turned off.',
        LocationFailureReason.denied => 'Location permission was denied.',
        LocationFailureReason.permanentlyDenied =>
          'Location permission is permanently denied.',
        LocationFailureReason.unavailable =>
          'Current location is unavailable.',
      };
    } on MissingPluginException {
      _clearLocation();
      _locationMessage = 'Location is unavailable on this platform.';
    } catch (_) {
      _clearLocation();
      _locationMessage = 'Could not retrieve your current location.';
    }

    if (notifyWhenDone) {
      notifyListeners();
    }
  }

  void _recalculateDistances() {
    _distancesByHouseId.clear();
    final location = _userLocation;
    if (location == null) return;

    for (final house in _allHouses) {
      final latitude = house.latitude;
      final longitude = house.longitude;
      if (latitude == null || longitude == null) continue;

      _distancesByHouseId[house.id] = _locationService.distanceInKm(
        from: location,
        latitude: latitude,
        longitude: longitude,
      );
    }
  }

  bool _matchesText(String? value, String query) {
    return value?.toLowerCase().contains(query) ?? false;
  }

  void _applyHouses(List<House> houses) {
    _allHouses = houses;
    _recalculateDistances();
    _sortHousesByDistance();
  }

  String _friendlyErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('timed out') || message.contains('Timeout')) {
      return 'The request timed out. Pull to refresh or try again.';
    }
    if (message.contains('offline') || message.contains('connection')) {
      return 'You appear to be offline. Saved listings will remain available when possible.';
    }
    if (message.contains('server') || message.contains('status')) {
      return 'The listings service is unavailable right now. Please try again soon.';
    }
    if (message.contains('read correctly')) {
      return 'Listings could not be read correctly. Please try again.';
    }

    return 'Could not load listings. Check your connection and try again.';
  }

  void _clearLocation() {
    _userLocation = null;
    _distancesByHouseId.clear();
  }

  void _sortHousesByDistance() {
    if (_distancesByHouseId.isEmpty) return;

    _allHouses = List<House>.from(_allHouses)
      ..sort((a, b) {
        final distanceA = _distancesByHouseId[a.id];
        final distanceB = _distancesByHouseId[b.id];

        if (distanceA == null && distanceB == null) return 0;
        if (distanceA == null) return 1;
        if (distanceB == null) return -1;
        return distanceA.compareTo(distanceB);
      });
  }
}
