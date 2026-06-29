import '../data/landlord_profile_repository.dart';
import '../models/landlord_profile.dart';
import '../models/landlord_registration_data.dart';

class LandlordProfileService {
  LandlordProfileService({LandlordProfileRepository? repository})
      : _repository = repository ?? LandlordProfileRepository();

  final LandlordProfileRepository _repository;

  Future<LandlordProfile> createVerifiedProfile(
    LandlordRegistrationData registrationData,
  ) async {
    await _repository.createProfile(registrationData);
    return _repository.getProfile(registrationData.phoneNumber);
  }
}
