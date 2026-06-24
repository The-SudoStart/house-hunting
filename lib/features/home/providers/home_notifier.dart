import 'package:flutter/material.dart';

import '../../../models/house.dart';
import '../../../services/house_service.dart';
import 'home_state.dart';

class HomeNotifier extends ChangeNotifier {
  final HouseService _houseService;

  HomeState _state = const HomeInitial();
  List<House> _allHouses = [];

  HomeNotifier(this._houseService);

  HomeState get state => _state;

  List<House> get allHouses => _allHouses;

  List<House> filteredHouses(String query) {
    if (query.isEmpty) return _allHouses;
    final searchLower = query.toLowerCase();
    return _allHouses.where((house) {
      return house.title.toLowerCase().contains(searchLower) ||
          house.city.toLowerCase().contains(searchLower) ||
          house.address.toLowerCase().contains(searchLower);
    }).toList();
  }

  Future<void> loadHouses() async {
    _state = const HomeLoading();
    notifyListeners();

    try {
      final houses = await _houseService.getHouses();
      _allHouses = houses;
      _state = HomeSuccess(houses);
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
}