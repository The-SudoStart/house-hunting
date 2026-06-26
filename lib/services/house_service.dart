import '../../models/house.dart';
import '../data/repositories/house_repository.dart';

/// Provides house listing data for the application.
///
/// Acts as a thin abstraction layer above [HouseRepository] so the UI
/// remains independent of networking implementation details. In the
/// future this class can also cache results, apply local filtering, or
/// orchestrate multiple repositories without changing the interface
/// consumed by the UI.
class HouseService {
  final HouseRepository _repository;

  HouseService({HouseRepository? repository})
      : _repository = repository ?? HouseRepository();

  /// Fetch all house listings.
  ///
  /// Delegates to [HouseRepository.getAllHouses]. Errors are propagated
  /// to the caller so the UI can handle them gracefully.
  Future<List<House>> getHouses() async {
    return _repository.getAllHouses();
  }

  Future<List<House>> getCachedHouses() async {
    return _repository.loadCachedHouses();
  }
}
