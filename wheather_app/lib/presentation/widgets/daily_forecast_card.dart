import 'package:flutter/material.dart';
import '../../domain/entities/daily_weather.dart';
import '../../domain/entities/weather_code_mapper.dart';
import '../utils/weather_icon_mapper.dart';
import '../utils/responsive.dart';

class DailyForecastCard extends StatelessWidget {
  final List<DailyWeather> dailyForecast;

  const DailyForecastCard({super.key, required this.dailyForecast});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '7-Tage',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...dailyForecast.map((d) => _DailyRow(daily: d)),
          ],
        ),
      ),
    );
  }
}

class _DailyRow extends StatelessWidget {
  final DailyWeather daily;

  const _DailyRow({required this.daily});

  @override
  Widget build(BuildContext context) {
    final weekday = _weekdayName(daily.date.weekday);
    final fontSize = Responsive.bodyFontSize(context);
    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              weekday,
              style: TextStyle(fontSize: fontSize - 1, fontWeight: FontWeight.w500),
            ),
          ),
          Icon(
            weatherIconFromCode(daily.weatherCode),
            color: weatherIconColor(daily.weatherCode),
            size: 20,
          ),
          const SizedBox(width: 8),
          if (!isMobile)
            Expanded(
              child: Text(
                weatherDescriptionFromCode(daily.weatherCode),
                style: TextStyle(fontSize: fontSize - 2, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (isMobile) const Spacer(),
          Text(
            '${daily.temperatureMin.round()}°',
            style: TextStyle(fontSize: fontSize - 1, color: Colors.blueGrey),
          ),
          const SizedBox(width: 6),
          Text(
            '${daily.temperatureMax.round()}°',
            style: TextStyle(fontSize: fontSize - 1, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mo';
      case 2: return 'Di';
      case 3: return 'Mi';
      case 4: return 'Do';
      case 5: return 'Fr';
      case 6: return 'Sa';
      case 7: return 'So';
      default: return '';
    }
  }
}
