import '../entities/location.dart';

abstract class LocationRepository {
  Future<UserLocation> getCurrentLocation();
}
