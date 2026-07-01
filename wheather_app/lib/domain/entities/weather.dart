import 'weather_code_mapper.dart';

class Weather {
  final double temperature;
  final double windSpeed;
  final int humidity;
  final int weatherCode;
  final DateTime time;

  Weather({
    required this.temperature,
    required this.windSpeed,
    required this.humidity,
    required this.weatherCode,
    required this.time,
  });

  String get weatherDescription => weatherDescriptionFromCode(weatherCode);
}
