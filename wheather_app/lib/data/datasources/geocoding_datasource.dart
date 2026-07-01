import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingDatasource {
  final http.Client client;

  GeocodingDatasource({http.Client? client})
      : client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> searchLocations(String query) async {
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search'
      '?name=${Uri.encodeComponent(query)}'
      '&count=5&language=de&format=json',
    );

    final response = await client.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>?;
      if (results == null) return [];
      return results.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Fehler bei der Ortssuche: ${response.statusCode}');
    }
  }
}
