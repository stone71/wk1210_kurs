import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/daily_weather.dart';
import '../../domain/entities/hourly_weather.dart';
import '../widgets/weather_header_card.dart';
import '../widgets/hourly_forecast_card.dart';
import '../widgets/daily_forecast_card.dart';
import '../utils/responsive.dart';

class DesktopWeatherLayout extends StatelessWidget {
  final Weather currentWeather;
  final List<HourlyWeather> hourlyForecast;
  final List<DailyWeather> dailyForecast;

  const DesktopWeatherLayout({
    super.key,
    required this.currentWeather,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.pagePadding(context);

    return Padding(
      padding: padding,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: WeatherHeaderCard(weather: currentWeather),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: DailyForecastCard(dailyForecast: dailyForecast),
              ),
            ],
          ),
          const SizedBox(height: 16),
          HourlyForecastCard(hourlyForecast: hourlyForecast),
        ],
      ),
    );
  }
}
