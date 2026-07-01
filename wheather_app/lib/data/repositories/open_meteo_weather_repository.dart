import '../../domain/entities/weather.dart';
import '../../domain/entities/daily_weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/open_meteo_datasource.dart';

class OpenMeteoWeatherRepository implements WeatherRepository {
  final OpenMeteoDatasource datasource;

  OpenMeteoWeatherRepository({required this.datasource});

  @override
  Future<Weather> getCurrentWeather(double latitude, double longitude) async {
    final data = await datasource.fetchCurrentWeather(latitude, longitude);
    final current = data['current'] as Map<String, dynamic>;

    return Weather(
      temperature: (current['temperature_2m'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      weatherCode: (current['weather_code'] as num).toInt(),
      time: DateTime.parse(current['time'] as String),
    );
  }

  @override
  Future<List<DailyWeather>> getDailyForecast(
      double latitude, double longitude) async {
    final data = await datasource.fetchDailyForecast(latitude, longitude);
    final daily = data['daily'] as Map<String, dynamic>;

    final times = (daily['time'] as List).cast<String>();
    final maxTemps = (daily['temperature_2m_max'] as List).cast<num>();
    final minTemps = (daily['temperature_2m_min'] as List).cast<num>();
    final codes = (daily['weather_code'] as List).cast<num>();

    return List.generate(times.length, (i) {
      return DailyWeather(
        date: DateTime.parse(times[i]),
        temperatureMax: maxTemps[i].toDouble(),
        temperatureMin: minTemps[i].toDouble(),
        weatherCode: codes[i].toInt(),
      );
    });
  }
}
