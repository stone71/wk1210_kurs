import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';
import '../utils/weather_icon_mapper.dart';
import '../utils/responsive.dart';

class WeatherHeaderCard extends StatelessWidget {
  final Weather weather;

  const WeatherHeaderCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final tempFontSize = Responsive.headerFontSize(context);
    final iconSize = isMobile ? 56.0 : 64.0;
    final descSize = isMobile ? 16.0 : 18.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF42A5F5),
      margin: isMobile ? const EdgeInsets.all(12) : EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              weatherIconFromCode(weather.weatherCode),
              size: iconSize,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              '${weather.temperature.round()}°',
              style: TextStyle(
                color: Colors.white,
                fontSize: tempFontSize,
                fontWeight: FontWeight.w200,
              ),
            ),
            Text(
              weather.weatherDescription,
              style: TextStyle(
                color: Colors.white70,
                fontSize: descSize,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Gefühlt ${weather.apparentTemperature.round()}°',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(Icons.air, '${weather.windSpeed.round()} km/h', 'Wind'),
                _buildDetailItem(Icons.water_drop_outlined, '${weather.humidity}%', 'Feuchte'),
                _buildDetailItem(Icons.thermostat, '${weather.apparentTemperature.round()}°', 'Gefühlt'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }
}
