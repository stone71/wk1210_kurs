# Weather App

Eine Flutter-Wetter-App, die aktuelle Wetterdaten und Vorhersagen anzeigt. Das Projekt folgt den Prinzipien der Clean Architecture und ist so aufgebaut, dass die Datenquelle jederzeit ausgetauscht werden kann.

## Projektstruktur

```
lib/
├── main.dart                              App-Einstiegspunkt
├── domain/                                Business-Logik (keine externen Abhängigkeiten)
│   ├── entities/
│   │   ├── weather.dart                   Entity: aktuelles Wetter
│   │   ├── daily_weather.dart             Entity: Tagesvorhersage
│   │   ├── hourly_weather.dart            Entity: stündliche Vorhersage
│   │   └── weather_code_mapper.dart       WMO-Wettercode → Beschreibung
│   └── repositories/
│       └── weather_repository.dart        Abstraktes Repository-Interface
├── data/                                  Datenquellen-Implementierung
│   ├── datasources/
│   │   └── open_meteo_datasource.dart     HTTP-Zugriff auf Open-Meteo API
│   └── repositories/
│       └── open_meteo_weather_repository.dart  Konkrete Implementierung
└── presentation/                          UI-Schicht
    ├── pages/
    │   └── weather_page.dart              Hauptseite mit Wetteranzeige
    └── utils/
        └── weather_icon_mapper.dart       Wettercode → Icon/Farbe
```

## Architektur

Das Projekt folgt dem Clean-Architecture-Ansatz mit drei Schichten:

### Domain Layer
Enthält die Entities und das abstrakte Repository-Interface. Diese Schicht hat keine Abhängigkeit zu Flutter, HTTP oder anderen Paketen. Sie definiert, welche Daten die App benötigt, ohne zu wissen, woher sie kommen.

### Data Layer
Implementiert das Repository-Interface aus der Domain-Schicht. Hier findet der konkrete API-Zugriff statt. Durch die Trennung von Datasource (HTTP-Logik) und Repository (Mapping auf Entities) kann die Datenquelle unabhängig ausgetauscht werden.

### Presentation Layer
Die UI-Schicht kennt nur das abstrakte Repository-Interface. Sie rendert die Daten unabhängig davon, ob sie von Open-Meteo, einem eigenen Backend oder einer lokalen Datenbank stammen.

## Datenquelle austauschen

Um eine andere API anzubinden:

1. Neue Datasource erstellen unter `lib/data/datasources/`
2. Neues Repository erstellen, das `WeatherRepository` implementiert
3. In `main.dart` die Instanz tauschen:

```dart
// Vorher:
final repository = OpenMeteoWeatherRepository(datasource: OpenMeteoDatasource());

// Nachher:
final repository = MeinEigenesWeatherRepository(datasource: MeineDatasource());
```

## Design

Das UI orientiert sich am Aufbau von wetter.de und zeigt:

- Header mit Ortsname, aktuellem Wetter-Icon, Temperatur und gefühlter Temperatur
- Detail-Karte mit Wind, Luftfeuchtigkeit und gefühlter Temperatur
- Stündliche Vorhersage (24h, horizontal scrollbar)
- 7-Tage-Vorhersage mit Wochentag, Icon, Beschreibung und Min/Max-Temperatur
- Pull-to-Refresh zum Aktualisieren

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

### Open-Meteo Geocoding API (vorbereitet, noch nicht implementiert)

- URL: `https://geocoding-api.open-meteo.com/v1/search`
- Zweck: Ortssuche nach Name → Koordinaten
- Beispiel: `?name=Gießen&count=5&language=de`

## Voraussetzungen

- Flutter SDK ≥ 3.11.5
- Internetverbindung (für API-Zugriffe)

## Starten

```bash
flutter pub get
flutter run
```

## Abhängigkeiten

| Paket | Zweck |
|-------|-------|
| `http` | HTTP-Anfragen an die Open-Meteo API |
| `cupertino_icons` | iOS-Style Icons |
