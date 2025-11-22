import 'package:flutter/material.dart';
import 'package:icon_forest/iconoir.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/screens/home/home_screen.dart';
import 'package:weather/weather.dart';

import 'package:geolocator/geolocator.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.',
    );
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  WeatherFactory wf = WeatherFactory(openWeatherApiKey);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: wf.currentWeatherByLocation(lat, lon),
      builder: (context, snapshot) {
        // Checking if future is resolved
        if (snapshot.connectionState == ConnectionState.done) {
          // If we got an error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${snapshot.error} occurred',
                style: TextStyle(fontSize: 18),
              ),
            );

            // if we got our data
          } else if (snapshot.hasData) {
            // Extracting data from snapshot object
            final weather = snapshot.data;
            final weatherLocation = weather?.areaName;
            final temp = weather?.temperature?.celsius?.toInt();
            final date = weather?.date;
            final formattedDate = DateFormat.MMMEd().format(date!);
            final wind = weather?.windSpeed;
            final humidity = weather?.humidity;
            // final visibility = weather?.;
            final pressure = weather?.pressure;
            final cloud = weather?.cloudiness;
            final icon = weather?.weatherIcon;
            final feelsLike = weather?.tempFeelsLike;

            final iconUrl = 'https://openweathermap.org/img/wn/${icon}@2x.png';

            final weatherDescription = weather?.weatherDescription;
            // double temp=w.temperature.celcius;
            // double celsius = snapshot.temperature.celsius;
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3B82F6),
                    Color(0xFF1D4ED8),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Section
                  _CurrentWeatherDetails(
                    weatherLocation: weatherLocation,
                    iconUrl: iconUrl,
                    temp: temp,
                    weatherDescription: weatherDescription,
                    feelsLike: feelsLike,
                    humidity: humidity,
                    wind: wind,
                    cloud: cloud,
                    pressure: pressure,
                  ),

                  const SizedBox(height: 24),

                  Container(
                    height: 1,
                    color: Colors.white.withOpacity(0.2),
                  ),

                  const SizedBox(height: 16),

                  // Forecast Row
                  _FiveDayForecastWidget(),
                ],
              ),
            );
          }
        }
        return SizedBox();
      },
    );
  }
}

class _CurrentWeatherDetails extends StatelessWidget {
  const _CurrentWeatherDetails({
    super.key,
    required this.weatherLocation,
    required this.iconUrl,
    required this.temp,
    required this.weatherDescription,
    required this.feelsLike,
    required this.humidity,
    required this.wind,
    required this.cloud,
    required this.pressure,
  });

  final String? weatherLocation;
  final String iconUrl;
  final int? temp;
  final String? weatherDescription;
  final Temperature? feelsLike;
  final double? humidity;
  final double? wind;
  final double? cloud;
  final double? pressure;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Location",
                  style: TextStyle(
                    color: Color(0xFFBFDBFE),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  weatherLocation ?? 'N/A',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            // Icon(
            //   Icons.cloud,
            //   size: 36,
            //   color: Color(0xFFBFDBFE),
            // ),
            Image.network(
              iconUrl,
              width: 44,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Temperature + Condition
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(temp ?? 0).toString()}°',
                  style: TextStyle(
                    fontSize: 64,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "F",
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFFBFDBFE),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  weatherDescription ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Feels like ${(feelsLike?.celsius ?? 0).toStringAsFixed(2)}°F",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFBFDBFE),
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Divider
        Container(
          height: 1,
          color: Colors.white.withOpacity(0.2),
        ),

        const SizedBox(height: 16),

        // Weather Details
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _WeatherDetail(
              icon: Icons.water_drop,
              label: "Humidity",
              value: '${(humidity ?? 0).toString()} %',
            ),
            _WeatherDetail(
              icon: Icons.air,
              label: "Wind",
              value: '${(wind ?? 0).toString()} mph',
            ),
            _WeatherDetail(
              icon: Icons.cloud,
              label: "Cloudiness",
              value: '${cloud ?? 0.toString()} okta',
            ),
            _WeatherDetail(
              icon: Icons.speed,
              label: "Pressure",
              value: '${(pressure ?? 0).toString()} mb',
            ),
          ],
        ),
      ],
    );
  }
}

class _FiveDayForecastWidget extends StatelessWidget {
  const _FiveDayForecastWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _ForecastItem(day: "Mon", icon: "☀️", temp: "75°"),
        _ForecastItem(day: "Tue", icon: "⛅", temp: "73°"),
        _ForecastItem(day: "Wed", icon: "🌧️", temp: "70°"),
        _ForecastItem(day: "Thu", icon: "🌧️", temp: "68°"),
        _ForecastItem(day: "Fri", icon: "⛅", temp: "72°"),
      ],
    );
  }
}

class _WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Color(0xFFBFDBFE)),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFFBFDBFE),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _ForecastItem extends StatelessWidget {
  final String day;
  final String icon;
  final String temp;

  const _ForecastItem({
    required this.day,
    required this.icon,
    required this.temp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFBFDBFE),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          icon,
          style: const TextStyle(fontSize: 26),
        ),
        const SizedBox(height: 4),
        Text(
          temp,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
