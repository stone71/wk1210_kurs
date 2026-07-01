import '../entities/location.dart';

abstract class GeocodingRepository {
  Future<List<UserLocation>> searchLocations(String query);
}
