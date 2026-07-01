import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/daily_weather.dart';
import '../../domain/entities/hourly_weather.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/geocoding_repository.dart';
import '../utils/responsive.dart';
import '../widgets/weather_top_bar.dart';
import '../widgets/weather_search.dart';
import '../layouts/mobile_weather_layout.dart';
import '../layouts/tablet_weather_layout.dart';
import '../layouts/desktop_weather_layout.dart';

class WeatherPage extends StatefulWidget {
  final WeatherRepository weatherRepository;
  final LocationRepository locationRepository;
  final GeocodingRepository geocodingRepository;

  const WeatherPage({
    super.key,
    required this.weatherRepository,
    required this.locationRepository,
    required this.geocodingRepository,
  });

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  UserLocation? _location;
  Weather? _currentWeather;
  List<DailyWeather>? _dailyForecast;
  List<HourlyWeather>? _hourlyForecast;
  bool _isLoading = true;
  String? _error;

  final TextEditingController _searchController = TextEditingController();
  List<UserLocation>? _searchResults;
  bool _isSearching = false;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final location = await widget.locationRepository.getCurrentLocation();
      await _loadWeatherForLocation(location);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadWeatherForLocation(UserLocation location) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final lat = location.latitude;
      final lon = location.longitude;

      final results = await Future.wait([
        widget.weatherRepository.getCurrentWeather(lat, lon),
        widget.weatherRepository.getDailyForecast(lat, lon),
        widget.weatherRepository.getHourlyForecast(lat, lon),
      ]);

      setState(() {
        _location = location;
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

  Future<void> _searchLocations(String query) async {
    if (query.trim().length < 2) {
      setState(() => _searchResults = null);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await widget.geocodingRepository.searchLocations(query.trim());
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (_) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  void _selectLocation(UserLocation location) {
    setState(() {
      _showSearch = false;
      _searchResults = null;
      _searchController.clear();
    });
    _loadWeatherForLocation(location);
  }

  void _resetToCurrentLocation() {
    setState(() {
      _showSearch = false;
      _searchResults = null;
      _searchController.clear();
    });
    _loadCurrentLocation();
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchResults = null;
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Wetterdaten werden geladen...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorView();
    }

    final screenType = Responsive.getScreenType(context);
    final maxWidth = Responsive.contentMaxWidth(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: () => _loadWeatherForLocation(_location!),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WeatherTopBar(
                    location: _location!,
                    showSearch: _showSearch,
                    onToggleSearch: _toggleSearch,
                    onResetLocation: _resetToCurrentLocation,
                  ),
                  if (_showSearch)
                    WeatherSearch(
                      controller: _searchController,
                      isSearching: _isSearching,
                      searchResults: _searchResults,
                      onChanged: _searchLocations,
                      onLocationSelected: _selectLocation,
                    ),
                  _buildLayout(screenType),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayout(ScreenType screenType) {
    switch (screenType) {
      case ScreenType.mobile:
        return MobileWeatherLayout(
          currentWeather: _currentWeather!,
          hourlyForecast: _hourlyForecast!,
          dailyForecast: _dailyForecast!,
        );
      case ScreenType.tablet:
        return TabletWeatherLayout(
          currentWeather: _currentWeather!,
          hourlyForecast: _hourlyForecast!,
          dailyForecast: _dailyForecast!,
        );
      case ScreenType.desktop:
        return DesktopWeatherLayout(
          currentWeather: _currentWeather!,
          hourlyForecast: _hourlyForecast!,
          dailyForecast: _dailyForecast!,
        );
    }
  }

  Widget _buildErrorView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Standort konnte nicht ermittelt werden',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadCurrentLocation,
                icon: const Icon(Icons.refresh),
                label: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
