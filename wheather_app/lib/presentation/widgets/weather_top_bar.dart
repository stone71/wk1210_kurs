import 'package:flutter/material.dart';
import '../../domain/entities/location.dart';

class WeatherTopBar extends StatelessWidget {
  final UserLocation location;
  final bool showSearch;
  final VoidCallback onToggleSearch;
  final VoidCallback onResetLocation;

  const WeatherTopBar({
    super.key,
    required this.location,
    required this.showSearch,
    required this.onToggleSearch,
    required this.onResetLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1976D2), Color(0xFF1E88E5)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.my_location, color: Colors.white70, size: 20),
                onPressed: onResetLocation,
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
                  showSearch ? Icons.close : Icons.search,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: onToggleSearch,
                tooltip: 'Ort suchen',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
