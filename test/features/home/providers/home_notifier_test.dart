import 'package:flutter_test/flutter_test.dart';

import 'package:house_finder/features/home/providers/home_notifier.dart';
import 'package:house_finder/features/home/providers/home_state.dart';
import 'package:house_finder/data/repositories/house_repository.dart';
import 'package:house_finder/models/house.dart';
import 'package:house_finder/services/house_service.dart';

class _FakeHouseRepository extends HouseRepository {
  final List<House> _houses;
  final bool _shouldFail;

  _FakeHouseRepository(this._houses, this._shouldFail);

  @override
  Future<List<House>> getAllHouses() async {
    if (_shouldFail) {
      throw Exception('API error');
    }
    return _houses;
  }
}

void main() {
  final testHouses = [
    House(
      id: 1,
      title: 'Test House',
      price: 100000,
      address: '123 Test St',
      city: 'Testville',
      landlordPhone: '+1234567890',
    ),
    House(
      id: 2,
      title: 'Another House',
      price: 200000,
      address: '456 Other Ave',
      city: 'Othertown',
      landlordPhone: '+0987654321',
    ),
  ];

  group('HomeNotifier', () {
    test('initial state is HomeInitial', () {
      final notifier = HomeNotifier(
        HouseService(repository: _FakeHouseRepository([], false)),
      );
      expect(notifier.state, isA<HomeInitial>());
      expect(notifier.allHouses, isEmpty);
    });

    test('loadHouses emits HomeLoading then HomeSuccess', () async {
      final notifier = HomeNotifier(
        HouseService(repository: _FakeHouseRepository(testHouses, false)),
      );

      final states = <HomeState>[];
      notifier.addListener(() {
        states.add(notifier.state);
      });

      await notifier.loadHouses();

      expect(states.length, 2);
      expect(states[0], isA<HomeLoading>());
      expect(states[1], isA<HomeSuccess>());

      final success = states[1] as HomeSuccess;
      expect(success.houses.length, 2);
      expect(success.houses[0].title, 'Test House');
    });

    test('loadHouses populates allHouses on success', () async {
      final notifier = HomeNotifier(
        HouseService(repository: _FakeHouseRepository(testHouses, false)),
      );

      await notifier.loadHouses();

      expect(notifier.allHouses.length, 2);
    });

    test('loadHouses emits HomeLoading then HomeError on failure', () async {
      final notifier = HomeNotifier(
        HouseService(repository: _FakeHouseRepository([], true)),
      );

      final states = <HomeState>[];
      notifier.addListener(() {
        states.add(notifier.state);
      });

      await notifier.loadHouses();

      expect(states.length, 2);
      expect(states[0], isA<HomeLoading>());
      expect(states[1], isA<HomeError>());

      final error = states[1] as HomeError;
      expect(error.message, contains('Failed to load houses'));
    });

    test('filteredHouses returns all houses when query is empty', () async {
      final notifier = HomeNotifier(
        HouseService(repository: _FakeHouseRepository(testHouses, false)),
      );
      await notifier.loadHouses();

      final result = notifier.filteredHouses('');
      expect(result.length, 2);
    });

    test('filteredHouses filters by title', () async {
      final notifier = HomeNotifier(
        HouseService(repository: _FakeHouseRepository(testHouses, false)),
      );
      await notifier.loadHouses();

      final result = notifier.filteredHouses('Test');
      expect(result.length, 1);
      expect(result[0].title, 'Test House');
    });

    test('filteredHouses filters by city', () async {
      final notifier = HomeNotifier(
        HouseService(repository: _FakeHouseRepository(testHouses, false)),
      );
      await notifier.loadHouses();

      final result = notifier.filteredHouses('Other');
      expect(result.length, 1);
      expect(result[0].city, 'Othertown');
    });

    test('filteredHouses returns empty list for no match', () async {
      final notifier = HomeNotifier(
        HouseService(repository: _FakeHouseRepository(testHouses, false)),
      );
      await notifier.loadHouses();

      final result = notifier.filteredHouses('xyzabc');
      expect(result, isEmpty);
    });

    test('retry delegates to loadHouses', () async {
      final notifier = HomeNotifier(
        HouseService(repository: _FakeHouseRepository(testHouses, false)),
      );

      final states = <HomeState>[];
      notifier.addListener(() {
        states.add(notifier.state);
      });

      notifier.retry();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(states.length, 2);
      expect(states[0], isA<HomeLoading>());
      expect(states[1], isA<HomeSuccess>());
    });
  });
}