import '../../../models/house.dart';
import '../../../services/house_service.dart';

abstract class HouseRepository {
  Future<List<House>> getHouses();
}

class HouseRepositoryImpl implements HouseRepository {
  @override
  Future<List<House>> getHouses() => HouseService.getHouses();
}