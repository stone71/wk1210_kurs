import 'package:flutter/material.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/daily_weather.dart';
import '../../domain/entities/hourly_weather.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/geocoding_repository.dart';
import '../utils/weather_icon_mapper.dart';
import '../utils/responsive.dart';
import '../../domain/entities/weather_code_mapper.dart';

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

  // Suche
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: () => _loadWeatherForLocation(_location!),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenType = Responsive.getScreenType(context);
            final maxWidth = Responsive.contentMaxWidth(context);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      if (_showSearch) _buildSearchSection(),
                      if (screenType == ScreenType.mobile)
                        ..._buildMobileContent()
                      else
                        _buildWideContent(screenType),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildMobileContent() {
    return [
      _buildCurrentDetails(),
      _buildHourlySection(),
      _buildDailySection(),
    ];
  }

  Widget _buildWideContent(ScreenType screenType) {
    final padding = Responsive.pagePadding(context);
    return Padding(
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
    );
  }

  Widget _buildHeader() {
    final weather = _currentWeather!;
    final location = _location!;
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
              // Ortsname + Such-Button + GPS-Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.my_location, color: Colors.white70, size: 20),
                    onPressed: _resetToCurrentLocation,
                    tooltip: 'Mein Standort',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.location_on, color: Colors.white70, size: 16),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      location.cityName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _showSearch ? Icons.close : Icons.search,
                      color: Colors.white70,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _showSearch = !_showSearch;
                        if (!_showSearch) {
                          _searchResults = null;
                          _searchController.clear();
                        }
                      });
                    },
                    tooltip: 'Ort suchen',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Ort suchen...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: _searchLocations,
            textInputAction: TextInputAction.search,
          ),
          if (_searchResults != null && _searchResults!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResults!.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final loc = _searchResults![index];
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined, size: 20),
                    title: Text(
                      loc.cityName,
                      style: const TextStyle(fontSize: 14),
                    ),
                    dense: true,
                    onTap: () => _selectLocation(loc),
                  );
                },
              ),
            ),
          if (_searchResults != null && _searchResults!.isEmpty && !_isSearching)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Keine Ergebnisse gefunden',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

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
                  itemCount: hourly.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final h = hourly[index];
                    return _buildHourlyItem(h);
                  },
                ),
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
