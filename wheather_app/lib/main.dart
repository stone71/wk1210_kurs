import 'package:flutter/material.dart';
import 'data/datasources/open_meteo_datasource.dart';
import 'data/repositories/open_meteo_weather_repository.dart';
import 'domain/repositories/weather_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherRepository _repository = OpenMeteoWeatherRepository(
    datasource: OpenMeteoDatasource(),
  );

  String _info = 'Lade Wetterdaten...';

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final weather = await _repository.getCurrentWeather(50.58, 8.67);
      final forecast = await _repository.getDailyForecast(50.58, 8.67);

      setState(() {
        _info = 'Aktuell: ${weather.temperature}°C – ${weather.weatherDescription}\n'
            'Wind: ${weather.windSpeed} km/h, Luftfeuchtigkeit: ${weather.humidity}%\n\n'
            'Vorhersage:\n'
            '${forecast.map((d) => '${d.date.day}.${d.date.month}: ${d.temperatureMin}°–${d.temperatureMax}°C').join('\n')}';
      });
    } catch (e) {
      setState(() {
        _info = 'Fehler: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_info, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
