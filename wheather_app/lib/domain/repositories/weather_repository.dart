import '../entities/weather.dart';
import '../entities/daily_weather.dart';

abstract class WeatherRepository {
  Future<Weather> getCurrentWeather(double latitude, double longitude);
  Future<List<DailyWeather>> getDailyForecast(double latitude, double longitude);
}
