import 'weather_code_mapper.dart';

class DailyWeather {
  final DateTime date;
  final double temperatureMax;
  final double temperatureMin;
  final int weatherCode;

  DailyWeather({
    required this.date,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.weatherCode,
  });

  String get weatherDescription => weatherDescriptionFromCode(weatherCode);
}
