import 'package:flutter/material.dart';
import 'data/datasources/open_meteo_datasource.dart';
import 'data/datasources/location_datasource.dart';
import 'data/repositories/open_meteo_weather_repository.dart';
import 'data/repositories/device_location_repository.dart';
import 'presentation/pages/weather_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherRepository = OpenMeteoWeatherRepository(
      datasource: OpenMeteoDatasource(),
    );
    final locationRepository = DeviceLocationRepository(
      datasource: LocationDatasource(),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1976D2)),
        useMaterial3: true,
      ),
      home: WeatherPage(
        weatherRepository: weatherRepository,
        locationRepository: locationRepository,
      ),
    );
  }
}
