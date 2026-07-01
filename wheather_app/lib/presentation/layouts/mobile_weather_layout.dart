import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/daily_weather.dart';
import '../../domain/entities/hourly_weather.dart';
import '../widgets/weather_header_card.dart';
import '../widgets/hourly_forecast_card.dart';
import '../widgets/daily_forecast_card.dart';

class MobileWeatherLayout extends StatelessWidget {
  final Weather currentWeather;
  final List<HourlyWeather> hourlyForecast;
  final List<DailyWeather> dailyForecast;

  const MobileWeatherLayout({
    super.key,
    required this.currentWeather,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WeatherHeaderCard(weather: currentWeather),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: HourlyForecastCard(hourlyForecast: hourlyForecast),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: DailyForecastCard(dailyForecast: dailyForecast),
        ),
      ],
    );
  }
}
