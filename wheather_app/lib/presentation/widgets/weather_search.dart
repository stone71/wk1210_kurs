import 'package:flutter/material.dart';
import '../../domain/entities/location.dart';

class WeatherSearch extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearching;
  final List<UserLocation>? searchResults;
  final ValueChanged<String> onChanged;
  final ValueChanged<UserLocation> onLocationSelected;

  const WeatherSearch({
    super.key,
    required this.controller,
    required this.isSearching,
    required this.searchResults,
    required this.onChanged,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Ort suchen...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: isSearching
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
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
          ),
          if (searchResults != null && searchResults!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: searchResults!.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final loc = searchResults![index];
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined, size: 20),
                    title: Text(
                      loc.cityName,
                      style: const TextStyle(fontSize: 14),
                    ),
                    dense: true,
                    onTap: () => onLocationSelected(loc),
                  );
                },
              ),
            ),
          if (searchResults != null && searchResults!.isEmpty && !isSearching)
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
}
