# Weather App

Eine Flutter-Wetter-App, die aktuelle Wetterdaten und Vorhersagen basierend auf dem aktuellen Standort anzeigt. Das Projekt folgt den Prinzipien der Clean Architecture mit klarer Schichttrennung und responsivem Design für Handy, Tablet und Desktop.

## Features

- Aktuelle Wetterdaten mit Temperatur, gefühlter Temperatur, Wind und Luftfeuchtigkeit
- Stündliche Vorhersage (24h, horizontal scrollbar)
- 7-Tage-Vorhersage mit Wettericons und Min/Max-Temperaturen
- Automatische Standorterkennung per GPS
- Ortssuche mit Live-Vorschlägen
- Zurücksetzen auf den eigenen Standort per GPS-Button
- Pull-to-Refresh zum Aktualisieren
- Responsives Layout für Handy, Tablet und Desktop

## Projektstruktur

```
lib/
├── main.dart                                    App-Einstiegspunkt
├── domain/                                      Business-Logik (keine externen Abhängigkeiten)
│   ├── entities/
│   │   ├── weather.dart                         Entity: aktuelles Wetter
│   │   ├── daily_weather.dart                   Entity: Tagesvorhersage
│   │   ├── hourly_weather.dart                  Entity: stündliche Vorhersage
│   │   ├── location.dart                        Entity: Standort (lat, lon, Name)
│   │   └── weather_code_mapper.dart             WMO-Wettercode → Beschreibung
│   └── repositories/
│       ├── weather_repository.dart              Abstraktes Weather-Interface
│       ├── location_repository.dart             Abstraktes Location-Interface
│       └── geocoding_repository.dart            Abstraktes Geocoding-Interface
├── data/                                        Datenquellen-Implementierung
│   ├── datasources/
│   │   ├── open_meteo_datasource.dart           HTTP-Zugriff auf Open-Meteo Weather API
│   │   ├── location_datasource.dart             GPS + Reverse-Geocoding (Nominatim)
│   │   └── geocoding_datasource.dart            Open-Meteo Geocoding API (Ortssuche)
│   └── repositories/
│       ├── open_meteo_weather_repository.dart   WeatherRepository-Implementierung
│       ├── device_location_repository.dart      LocationRepository-Implementierung
│       └── open_meteo_geocoding_repository.dart GeocodingRepository-Implementierung
└── presentation/                                UI-Schicht
    ├── pages/
    │   └── weather_page.dart                    State-Management + Layout-Entscheidung
    ├── widgets/
    │   ├── weather_top_bar.dart                 Ortsname, GPS-/Such-Button
    │   ├── weather_search.dart                  Suchfeld + Ergebnisliste
    │   ├── weather_header_card.dart             Große Temperaturanzeige + Details
    │   ├── hourly_forecast_card.dart            Stündliche Vorhersage
    │   └── daily_forecast_card.dart             7-Tage-Vorhersage
    ├── layouts/
    │   ├── mobile_weather_layout.dart           Anordnung für Handy (< 600px)
    │   ├── tablet_weather_layout.dart           Anordnung für Tablet (600–1200px)
    │   └── desktop_weather_layout.dart          Anordnung für Desktop (> 1200px)
    └── utils/
        ├── responsive.dart                      Breakpoints + Responsive-Helper
        └── weather_icon_mapper.dart             Wettercode → Icon/Farbe
```

## Architektur

Das Projekt folgt dem Clean-Architecture-Ansatz mit drei Schichten:

### Domain Layer

Enthält die Entities und abstrakten Repository-Interfaces. Diese Schicht hat keine Abhängigkeit zu Flutter, HTTP oder anderen Paketen. Sie definiert, welche Daten die App benötigt, ohne zu wissen, woher sie kommen.

### Data Layer

Implementiert die Repository-Interfaces aus der Domain-Schicht. Hier findet der konkrete API-Zugriff statt. Durch die Trennung von Datasource (HTTP-/Geräte-Logik) und Repository (Mapping auf Entities) kann jede Datenquelle unabhängig ausgetauscht werden.

### Presentation Layer

Die UI-Schicht kennt nur die abstrakten Repository-Interfaces. Sie ist in drei Bereiche unterteilt:

- **Pages** – Orchestrierung: Daten laden, State verwalten, Layout wählen
- **Widgets** – Wiederverwendbare UI-Bausteine, empfangen Daten als Props
- **Layouts** – Anordnung der Widgets je nach Bildschirmgröße

## Responsive Design

Das Layout passt sich automatisch an die Bildschirmbreite an:

| Gerät | Breite | Layout |
|-------|--------|--------|
| Handy | < 600px | Alles untereinander, kompakte Abstände |
| Tablet | 600–1200px | Header + 7-Tage nebeneinander, Stündlich darunter, max. 800px |
| Desktop | > 1200px | Wie Tablet, zentriert mit max. 1000px Breite |

Die Breakpoints und Helper-Funktionen liegen in `presentation/utils/responsive.dart`. Es wird kein externes Paket verwendet – Flutter's `MediaQuery` und `ConstrainedBox` reichen für diesen Anwendungsfall aus.

## Datenquelle austauschen

Um eine andere Wetter-API anzubinden:

1. Neue Datasource erstellen unter `lib/data/datasources/`
2. Neues Repository erstellen, das `WeatherRepository` implementiert
3. In `main.dart` die Instanz tauschen:

```dart
// Vorher:
final weatherRepository = OpenMeteoWeatherRepository(datasource: OpenMeteoDatasource());

// Nachher:
final weatherRepository = MeinWeatherRepository(datasource: MeineDatasource());
```

Der gleiche Mechanismus gilt für `LocationRepository` und `GeocodingRepository`.

## Externe Schnittstellen

### Open-Meteo Weather Forecast API

- URL: `https://api.open-meteo.com/v1/forecast`
- Dokumentation: [https://open-meteo.com/en/docs](https://open-meteo.com/en/docs)
- Authentifizierung: Keine (kein API-Key erforderlich)
- Nutzungsbedingungen: Kostenlos für nicht-kommerzielle Nutzung, max. 10.000 Aufrufe/Tag
- Lizenz: [CC BY 4.0](https://open-meteo.com/en/licence)

#### Genutzte Endpunkte

**Aktuelles Wetter**
```
GET /v1/forecast?latitude={lat}&longitude={lon}&current=temperature_2m,apparent_temperature,weather_code,wind_speed_10m,relative_humidity_2m&timezone=auto
```

**Tägliche Vorhersage (7 Tage)**
```
GET /v1/forecast?latitude={lat}&longitude={lon}&daily=temperature_2m_max,temperature_2m_min,weather_code&timezone=auto
```

**Stündliche Vorhersage (24h)**
```
GET /v1/forecast?latitude={lat}&longitude={lon}&hourly=temperature_2m,weather_code&forecast_hours=24&timezone=auto
```

#### Genutzte Wettervariablen

| Variable | Beschreibung | Einheit |
|----------|-------------|---------|
| `temperature_2m` | Temperatur auf 2m Höhe | °C |
| `apparent_temperature` | Gefühlte Temperatur | °C |
| `weather_code` | WMO-Wettercode | Code |
| `wind_speed_10m` | Windgeschwindigkeit auf 10m Höhe | km/h |
| `relative_humidity_2m` | Relative Luftfeuchtigkeit | % |
| `temperature_2m_max` | Tageshöchsttemperatur | °C |
| `temperature_2m_min` | Tagestiefsttemperatur | °C |

### Open-Meteo Geocoding API

- URL: `https://geocoding-api.open-meteo.com/v1/search`
- Zweck: Ortssuche nach Name → Koordinaten
- Authentifizierung: Keine
- Beispiel: `?name=Berlin&count=5&language=de&format=json`

Wird für die Live-Ortssuche im Suchfeld verwendet. Liefert bis zu 5 Treffer mit Name, Region, Land und Koordinaten.

### Nominatim (OpenStreetMap) – Reverse Geocoding

- URL: `https://nominatim.openstreetmap.org/reverse`
- Zweck: Koordinaten → Ortsname (für GPS-Standort)
- Authentifizierung: Keine (User-Agent erforderlich)
- Nutzungsbedingungen: Max. 1 Request/Sekunde
- Lizenz: [ODbL](https://opendatacommons.org/licenses/odbl/)

Wird verwendet, um nach der GPS-Ortung den lesbaren Stadtnamen zu ermitteln.

### Geolocator (Flutter-Paket)

- Paket: `geolocator` auf pub.dev
- Zweck: GPS-Position des Geräts ermitteln
- Berechtigungen: `ACCESS_FINE_LOCATION` (Android), `NSLocationWhenInUseUsageDescription` (iOS)

#### WMO-Wettercodes (Auszug)

| Code | Bedeutung |
|------|-----------|
| 0 | Klarer Himmel |
| 1, 2, 3 | Überwiegend klar, teilweise bewölkt, bewölkt |
| 45, 48 | Nebel |
| 51, 53, 55 | Nieselregen |
| 61, 63, 65 | Regen |
| 71, 73, 75 | Schneefall |
| 80, 81, 82 | Regenschauer |
| 95 | Gewitter |

## Voraussetzungen

- Flutter SDK ≥ 3.11.5
- Internetverbindung (für API-Zugriffe)
- Standortberechtigung (für GPS)

## Starten

```bash
flutter pub get
flutter run
```

## Abhängigkeiten

| Paket | Zweck |
|-------|-------|
| `http` | HTTP-Anfragen an Open-Meteo und Nominatim |
| `geolocator` | GPS-Standortermittlung |
| `cupertino_icons` | iOS-Style Icons |

## Entwicklungsverlauf

1. **Projekt-Setup** – Flutter-Projekt erstellt, Boilerplate bereinigt
2. **API-Recherche** – Open-Meteo als kostenlose Wetter-API identifiziert und Endpunkte dokumentiert
3. **Clean Architecture** – Domain-/Data-Schichttrennung mit abstrakten Repositories eingeführt
4. **Wetterdaten-Anbindung** – Open-Meteo Datasource + Repository für aktuelles Wetter und Vorhersage
5. **UI im wetter.de-Stil** – Header mit Temperatur, Detail-Karte, stündliche und tägliche Vorhersage
6. **Responsive Design** – Eigener Responsive-Helper mit drei Breakpoints (Handy/Tablet/Desktop)
7. **GPS-Standort** – Geolocator-Integration + Nominatim Reverse-Geocoding für Ortsnamen
8. **Ortssuche** – Open-Meteo Geocoding API mit Live-Vorschlägen und Ort-Wechsel
9. **Refactoring** – Zerlegung der monolithischen Page in Widgets und Layouts nach Clean Architecture
