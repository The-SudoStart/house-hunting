import 'package:geolocator/geolocator.dart';

class UserLocation {
  final double latitude;
  final double longitude;

  const UserLocation({
    required this.latitude,
    required this.longitude,
  });
}

enum LocationFailureReason {
  serviceDisabled,
  denied,
  permanentlyDenied,
  unavailable,
}

class LocationFailure implements Exception {
  final LocationFailureReason reason;

  const LocationFailure(this.reason);
}

class LocationService {
  Future<UserLocation> requestCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationFailure(LocationFailureReason.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationFailure(LocationFailureReason.denied);
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(LocationFailureReason.permanentlyDenied);
    }

    final position = await Geolocator.getCurrentPosition();
    return UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  double distanceInKm({
    required UserLocation from,
    required double latitude,
    required double longitude,
  }) {
    final meters = Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      latitude,
      longitude,
    );

    return meters / 1000;
  }
}
