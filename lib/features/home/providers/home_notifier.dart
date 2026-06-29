import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/house.dart';
import '../../../services/house_service.dart';
import '../../../services/location_service.dart';
import 'home_state.dart';

class HomeNotifier extends ChangeNotifier {
  final HouseService _houseService;
  final LocationService _locationService;

  HomeState _state = const HomeInitial();
  List<House> _allHouses = [];
  UserLocation? _userLocation;
  String? _locationMessage;
  final Map<int, double> _distancesByHouseId = {};

  HomeNotifier(
    this._houseService, {
    LocationService? locationService,
  }) : _locationService = locationService ?? LocationService();

  HomeState get state => _state;

  List<House> get allHouses => _allHouses;

  UserLocation? get userLocation => _userLocation;

  String? get locationMessage => _locationMessage;

  double? distanceForHouse(House house) => _distancesByHouseId[house.id];

  House? houseById(int id) {
    for (final house in _allHouses) {
      if (house.id == id) return house;
    }
    return null;
  }

  List<House> filteredHouses(String query) {
    if (query.isEmpty) return List<House>.unmodifiable(_allHouses);
    final searchLower = query.toLowerCase();
    return _allHouses.where((house) {
      return house.title.toLowerCase().contains(searchLower) ||
          house.city.toLowerCase().contains(searchLower) ||
          house.address.toLowerCase().contains(searchLower);
    }).toList(growable: false);
  }

  Future<void> loadHouses() async {
    _state = const HomeLoading();
    notifyListeners();

    try {
      final houses = await _houseService.getHouses();
      _allHouses = houses;
      await _refreshLocation(notifyWhenDone: false);
      _sortHousesByDistance();
      _state = HomeSuccess(_allHouses);
      notifyListeners();
    } catch (e) {
      _state = const HomeError(
        'Failed to load houses. Please check your connection and try again.',
      );
      notifyListeners();
    }
  }

  void retry() {
    loadHouses();
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
