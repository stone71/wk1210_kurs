import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/daily_weather.dart';
import '../../domain/entities/hourly_weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../utils/weather_icon_mapper.dart';
import '../utils/responsive.dart';
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenType = Responsive.getScreenType(context);
            final maxWidth = Responsive.contentMaxWidth(context);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: screenType == ScreenType.mobile
                      ? _buildMobileLayout()
                      : _buildWideLayout(screenType),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        _buildCurrentDetails(),
        _buildHourlySection(),
        _buildDailySection(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildWideLayout(ScreenType screenType) {
    final padding = Responsive.pagePadding(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        Padding(
          padding: padding,
          child: screenType == ScreenType.desktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildCurrentDetailsCard(),
                          const SizedBox(height: 16),
                          _buildHourlyCard(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: _buildDailyCard(),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildCurrentDetailsCard()),
                        const SizedBox(width: 16),
                        Expanded(child: _buildDailyCard()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildHourlyCard(),
                  ],
                ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeader() {
    final weather = _currentWeather!;
    final tempFontSize = Responsive.headerFontSize(context);
    final isMobile = Responsive.isMobile(context);
    final iconSize = isMobile ? 56.0 : 64.0;
    final descSize = isMobile ? 16.0 : 18.0;

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
          padding: EdgeInsets.fromLTRB(24, isMobile ? 16 : 24, 24, isMobile ? 20 : 32),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Colors.white70, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Gießen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
            ],
          ),
        ),
      ),
    );
  }

  // Mobile-Version mit eigener Padding-Logik
  Widget _buildCurrentDetails() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: _buildCurrentDetailsCard(),
    );
  }

  Widget _buildCurrentDetailsCard() {
    final weather = _currentWeather!;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
              'Feuchte',
            ),
            _buildDetailItem(
              Icons.thermostat,
              '${weather.apparentTemperature.round()}°',
              'Gefühlt',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    final fontSize = Responsive.bodyFontSize(context);
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1976D2), size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: fontSize - 2, color: Colors.grey),
        ),
      ],
    );
  }

  // Mobile-Version
  Widget _buildHourlySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: _buildHourlyCard(),
    );
  }

  Widget _buildHourlyCard() {
    final hourly = _hourlyForecast!;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stündlich',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: hourly.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final h = hourly[index];
                  return _buildHourlyItem(h);
                },
              ),
            ),
          ],
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
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        Icon(
          weatherIconFromCode(h.weatherCode),
          color: weatherIconColor(h.weatherCode),
          size: 24,
        ),
        Text(
          '${h.temperature.round()}°',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // Mobile-Version
  Widget _buildDailySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: _buildDailyCard(),
    );
  }

  Widget _buildDailyCard() {
    final daily = _dailyForecast!;
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
            ...daily.map((d) => _buildDailyRow(d)),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyRow(DailyWeather d) {
    final weekday = _weekdayName(d.date.weekday);
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
            weatherIconFromCode(d.weatherCode),
            color: weatherIconColor(d.weatherCode),
            size: 20,
          ),
          const SizedBox(width: 8),
          if (!isMobile)
            Expanded(
              child: Text(
                weatherDescriptionFromCode(d.weatherCode),
                style: TextStyle(fontSize: fontSize - 2, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (isMobile) const Spacer(),
          Text(
            '${d.temperatureMin.round()}°',
            style: TextStyle(fontSize: fontSize - 1, color: Colors.blueGrey),
          ),
          const SizedBox(width: 6),
          Text(
            '${d.temperatureMax.round()}°',
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
