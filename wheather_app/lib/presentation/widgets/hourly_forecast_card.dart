import 'package:flutter/material.dart';
import '../../domain/entities/hourly_weather.dart';
import '../utils/weather_icon_mapper.dart';

class HourlyForecastCard extends StatelessWidget {
  final List<HourlyWeather> hourlyForecast;

  const HourlyForecastCard({super.key, required this.hourlyForecast});

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
            const Row(
              children: [
                Text(
                  'Stündlich',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 92,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.white, Colors.white, Colors.white, Colors.transparent],
                    stops: [0.0, 0.85, 0.92, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: hourlyForecast.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    return _HourlyItem(hourly: hourlyForecast[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HourlyItem extends StatelessWidget {
  final HourlyWeather hourly;

  const _HourlyItem({required this.hourly});

  @override
  Widget build(BuildContext context) {
    final hour = '${hourly.time.hour.toString().padLeft(2, '0')}:00';
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          hour,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        Icon(
          weatherIconFromCode(hourly.weatherCode),
          color: weatherIconColor(hourly.weatherCode),
          size: 24,
        ),
        Text(
          '${hourly.temperature.round()}°',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
