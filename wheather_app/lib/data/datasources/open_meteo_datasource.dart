import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenMeteoDatasource {
  final http.Client client;

  OpenMeteoDatasource({http.Client? client})
      : client = client ?? http.Client();

  Future<Map<String, dynamic>> fetchCurrentWeather(
      double latitude, double longitude) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,apparent_temperature,weather_code,wind_speed_10m,relative_humidity_2m'
      '&timezone=auto',
    );

    final response = await client.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Fehler beim Laden der aktuellen Wetterdaten: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchDailyForecast(
      double latitude, double longitude) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitude&longitude=$longitude'
      '&daily=temperature_2m_max,temperature_2m_min,weather_code'
      '&timezone=auto',
    );

    final response = await client.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Fehler beim Laden der Vorhersage: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchHourlyForecast(
      double latitude, double longitude) async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitude&longitude=$longitude'
      '&hourly=temperature_2m,weather_code'
      '&forecast_hours=24'
      '&timezone=auto',
    );

    final response = await client.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Fehler beim Laden der stündlichen Vorhersage: ${response.statusCode}');
    }
  }
}
