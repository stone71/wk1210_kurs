import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/daily_weather.dart';
import '../../domain/entities/hourly_weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../utils/weather_icon_mapper.dart';
import '../../domain/entities/weather_code_mapper.dart';

class WeatherPage extends StatefulWidget {
  final WeatherRepository repository;

  const WeatherPage({super.key, required this.repository});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Weather? _currentWeather;
  List<DailyWeather>? _dailyForecast;
  List<HourlyWeather>? _hourlyForecast;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final results = await Future.wait([
        widget.repository.getCurrentWeather(50.58, 8.67),
        widget.repository.getDailyForecast(50.58, 8.67),
        widget.repository.getHourlyForecast(50.58, 8.67),
      ]);

      setState(() {
        _currentWeather = results[0] as Weather;
        _dailyForecast = results[1] as List<DailyWeather>;
        _hourlyForecast = results[2] as List<HourlyWeather>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Fehler: $_error', style: const TextStyle(color: Colors.red)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _loadWeather,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              _buildCurrentDetails(),
              _buildHourlySection(),
              _buildDailySection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final weather = _currentWeather!;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Colors.white70, size: 18),
                  SizedBox(width: 4),
                  Text(
                    'Gießen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Icon(
                weatherIconFromCode(weather.weatherCode),
                size: 72,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                '${weather.temperature.round()}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 72,
                  fontWeight: FontWeight.w200,
                ),
              ),
              Text(
                weather.weatherDescription,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Gefühlt ${weather.apparentTemperature.round()}°',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentDetails() {
    final weather = _currentWeather!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailItem(
                Icons.air,
                '${weather.windSpeed.round()} km/h',
                'Wind',
              ),
              _buildDetailItem(
                Icons.water_drop_outlined,
                '${weather.humidity}%',
                'Luftfeuchtigkeit',
              ),
              _buildDetailItem(
                Icons.thermostat,
                '${weather.apparentTemperature.round()}°',
                'Gefühlt',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1976D2), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildHourlySection() {
    final hourly = _hourlyForecast!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stündlich',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: hourly.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final h = hourly[index];
                    return _buildHourlyItem(h);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyItem(HourlyWeather h) {
    final hour = '${h.time.hour.toString().padLeft(2, '0')}:00';
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          hour,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Icon(
          weatherIconFromCode(h.weatherCode),
          color: weatherIconColor(h.weatherCode),
          size: 28,
        ),
        Text(
          '${h.temperature.round()}°',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildDailySection() {
    final daily = _dailyForecast!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '7-Tage-Vorhersage',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...daily.map((d) => _buildDailyRow(d)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyRow(DailyWeather d) {
    final weekday = _weekdayName(d.date.weekday);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              weekday,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Icon(
            weatherIconFromCode(d.weatherCode),
            color: weatherIconColor(d.weatherCode),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              weatherDescriptionFromCode(d.weatherCode),
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${d.temperatureMin.round()}°',
            style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
          ),
          const SizedBox(width: 8),
          Text(
            '${d.temperatureMax.round()}°',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mo';
      case 2:
        return 'Di';
      case 3:
        return 'Mi';
      case 4:
        return 'Do';
      case 5:
        return 'Fr';
      case 6:
        return 'Sa';
      case 7:
        return 'So';
      default:
        return '';
    }
  }
}
