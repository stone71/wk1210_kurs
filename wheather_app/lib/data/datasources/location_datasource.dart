import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationDatasource {
  final http.Client client;

  LocationDatasource({http.Client? client})
      : client = client ?? http.Client();

  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Standortdienste sind deaktiviert.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Standortberechtigung verweigert.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Standortberechtigung dauerhaft verweigert. Bitte in den Einstellungen aktivieren.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
      ),
    );
  }

  Future<String> getCityName(double latitude, double longitude) async {
    final nominatimUrl = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=$latitude&lon=$longitude&format=json&accept-language=de',
    );

    try {
      final response = await client.get(
        nominatimUrl,
        headers: {'User-Agent': 'WeatherApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          return address['city'] as String? ??
              address['town'] as String? ??
              address['village'] as String? ??
              address['municipality'] as String? ??
              'Unbekannt';
        }
      }
    } catch (_) {
      // Fallback: keine Ortsname-Auflösung
    }

    return 'Mein Standort';
  }
}
