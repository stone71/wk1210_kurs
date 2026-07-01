import '../../domain/entities/location.dart';
import '../../domain/repositories/geocoding_repository.dart';
import '../datasources/geocoding_datasource.dart';

class OpenMeteoGeocodingRepository implements GeocodingRepository {
  final GeocodingDatasource datasource;

  OpenMeteoGeocodingRepository({required this.datasource});

  @override
  Future<List<UserLocation>> searchLocations(String query) async {
    final results = await datasource.searchLocations(query);

    return results.map((r) {
      final name = r['name'] as String? ?? 'Unbekannt';
      final admin1 = r['admin1'] as String?;
      final country = r['country'] as String?;

      final parts = [name, if (admin1 != null) admin1, if (country != null) country];
      final displayName = parts.join(', ');

      return UserLocation(
        latitude: (r['latitude'] as num).toDouble(),
        longitude: (r['longitude'] as num).toDouble(),
        cityName: displayName,
      );
    }).toList();
  }
}
