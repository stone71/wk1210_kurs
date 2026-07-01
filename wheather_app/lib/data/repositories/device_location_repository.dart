import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_datasource.dart';

class DeviceLocationRepository implements LocationRepository {
  final LocationDatasource datasource;

  DeviceLocationRepository({required this.datasource});

  @override
  Future<UserLocation> getCurrentLocation() async {
    final position = await datasource.getCurrentPosition();
    final cityName = await datasource.getCityName(
      position.latitude,
      position.longitude,
    );

    return UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      cityName: cityName,
    );
  }
}
