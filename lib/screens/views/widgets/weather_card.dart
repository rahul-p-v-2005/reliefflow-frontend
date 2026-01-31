import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
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
    return Future.error((
      message:
          'Location services are disabled. Enable location services in your device settings.',
      code: 'DISABLED',
    ));
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
      return Future.error((
        message: 'Location permissions are denied',
        code: 'DENIED',
      ));
    }
  }

  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error((
      message:
          'Location permissions are permanently denied, we cannot request permissions.',
      code: 'PERMANENTLY_DENIED',
    ));
  }

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.

  // First try to get the last known position (instant, cached)
  final lastKnown = await Geolocator.getLastKnownPosition();
  if (lastKnown != null) {
    return lastKnown;
  }

  // If no cached position, get current position using network-based location
  return await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.lowest,
    ),
  );
}

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> with WidgetsBindingObserver {
  Position? _cachedPosition;
  Weather? _cachedWeather;
  List<Weather>? _cachedForecast;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  bool _isServiceDisabled = false;

  final WeatherFactory _wf = WeatherFactory(openWeatherApiKey);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadWeatherData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auto-refresh when app resumes (user returns from settings)
    if (state == AppLifecycleState.resumed) {
      _refreshWeatherData();
    }
  }

  Future<void> _loadWeatherData() async {
    try {
      final position = await _determinePosition();

      // Fetch weather and forecast in parallel
      final results = await Future.wait([
        _wf.currentWeatherByLocation(position.latitude, position.longitude),
        _wf.fiveDayForecastByLocation(position.latitude, position.longitude),
      ]);

      if (mounted) {
        setState(() {
          _cachedPosition = position;
          _cachedWeather = results[0] as Weather;
          _cachedForecast = results[1] as List<Weather>;
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'An error occurred';
        bool isServiceDisabled = false;

        try {
          final errorRecord = e as ({String message, String code});
          errorMessage = errorRecord.message;
          isServiceDisabled = errorRecord.code == 'DISABLED';
        } catch (_) {
          errorMessage = e.toString();
        }

        setState(() {
          _isLoading = false;
          _isRefreshing = false;
          // Only set error if we don't have cached data
          if (_cachedWeather == null) {
            _errorMessage = errorMessage;
            _isServiceDisabled = isServiceDisabled;
          }
        });
      }
    }
  }

  Future<void> _refreshWeatherData() async {
    if (_isRefreshing) return;

    // If we have cached data, show refresh indicator instead of skeleton
    if (_cachedWeather != null) {
      setState(() {
        _isRefreshing = true;
      });
    }

    await _loadWeatherData();
  }

  @override
  Widget build(BuildContext context) {
    // Show skeleton while initial loading
    if (_isLoading && _cachedWeather == null) {
      return const _WeatherCardSkeleton();
    }

    // Show error card if no cached data and there's an error
    if (_errorMessage != null && _cachedWeather == null) {
      return _WeatherErrorCard(
        message: _errorMessage!,
        showRetry: !_isServiceDisabled,
        showOpenSettings: _isServiceDisabled,
        onRetry: () => _loadWeatherData(),
      );
    }

    // Show weather card with data
    if (_cachedWeather != null) {
      return Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
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
                // Current Weather
                _CurrentWeatherContent(weather: _cachedWeather!),
                const SizedBox(height: 8),
                // Forecast Row
                if (_cachedForecast != null)
                  _FiveDayForecastContent(forecast: _cachedForecast!),
              ],
            ),
          ),
          // Refresh indicator overlay
          if (_isRefreshing)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    // Fallback skeleton
    return const _WeatherCardSkeleton();
  }
}

/// Skeleton loader for weather card
class _WeatherCardSkeleton extends StatefulWidget {
  const _WeatherCardSkeleton();

  @override
  State<_WeatherCardSkeleton> createState() => _WeatherCardSkeletonState();
}

class _WeatherCardSkeletonState extends State<_WeatherCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF3B82F6).withOpacity(_animation.value + 0.4),
                Color(0xFF1D4ED8).withOpacity(_animation.value + 0.4),
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
              // Top row skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SkeletonBox(
                    width: 100,
                    height: 20,
                    opacity: _animation.value,
                  ),
                  _SkeletonBox(
                    width: 44,
                    height: 44,
                    opacity: _animation.value,
                    isCircle: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Temperature skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SkeletonBox(
                    width: 80,
                    height: 48,
                    opacity: _animation.value,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _SkeletonBox(
                        width: 80,
                        height: 18,
                        opacity: _animation.value,
                      ),
                      const SizedBox(height: 4),
                      _SkeletonBox(
                        width: 100,
                        height: 12,
                        opacity: _animation.value,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Forecast row skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (index) => Column(
                    children: [
                      _SkeletonBox(
                        width: 40,
                        height: 11,
                        opacity: _animation.value,
                      ),
                      const SizedBox(height: 4),
                      _SkeletonBox(
                        width: 40,
                        height: 11,
                        opacity: _animation.value,
                      ),
                      const SizedBox(height: 4),
                      _SkeletonBox(
                        width: 44,
                        height: 44,
                        opacity: _animation.value,
                        isCircle: true,
                      ),
                      const SizedBox(height: 4),
                      _SkeletonBox(
                        width: 30,
                        height: 14,
                        opacity: _animation.value,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double opacity;
  final bool isCircle;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.opacity,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: isCircle ? null : BorderRadius.circular(4),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}

/// Current weather content widget (no FutureBuilder, just displays data)
class _CurrentWeatherContent extends StatelessWidget {
  final Weather weather;

  const _CurrentWeatherContent({required this.weather});

  @override
  Widget build(BuildContext context) {
    final weatherLocation = weather.areaName;
    final temp = weather.temperature?.celsius?.toInt();
    final feelsLike = weather.tempFeelsLike;
    final weatherDescription = weather.weatherDescription;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weatherLocation ?? 'N/A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 44,
              height: 44,
              child: Image.network(
                _getWeatherIconUrl(weather.weatherIcon ?? ''),
                width: 44,
                height: 44,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Icon(
                    Icons.cloud,
                    size: 44,
                    color: Colors.white70,
                  );
                },
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.cloud,
                  size: 44,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(temp ?? 0).toString()}°',
                  style: const TextStyle(
                    fontSize: 48,
                    height: 1,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  weatherDescription ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Feels like ${(feelsLike?.celsius ?? 0).toStringAsFixed(0)}°",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFBFDBFE),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Five day forecast content widget (no FutureBuilder, just displays data)
class _FiveDayForecastContent extends StatelessWidget {
  final List<Weather> forecast;

  const _FiveDayForecastContent({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final next5 = forecast.take(5).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: next5.map((e) => _ForecastItem(weather: e)).toList(),
    );
  }
}

/// Error card widget with gradient background and typing animation
class _WeatherErrorCard extends StatelessWidget {
  final String message;
  final bool showRetry;
  final bool showOpenSettings;
  final VoidCallback onRetry;

  const _WeatherErrorCard({
    required this.message,
    required this.showRetry,
    required this.onRetry,
    this.showOpenSettings = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF64748B),
            Color(0xFF475569),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Location off icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (showOpenSettings)
            TextButton.icon(
              onPressed: () => Geolocator.openLocationSettings(),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.settings_rounded, size: 18),
              label: const Text('Open Location Settings'),
            ),
          if (showRetry)
            TextButton.icon(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
            ),
        ],
      ),
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
  final Weather weather;

  const _ForecastItem({
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final dateTime = weather.date ?? DateTime.now();

    print(dateTime);

    final currentDate = DateTime.now();

    final difference = dateTime.day - currentDate.day;

    //  Date (e.g. "Nov 23")
    final date = switch (difference) {
      0 => 'Today',
      1 => 'Tomorrow',
      _ => DateFormat.MMMd().format(dateTime),
    };

    //  Time (e.g. "03 PM")
    final time = DateFormat('hh a').format(dateTime);

    final temp = '${(weather.temperature?.celsius?.toInt() ?? 0).toString()}°';
    return Column(
      children: [
        // Date
        Text(
          date,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFBFDBFE),
          ),
        ),
        // SizedBox(height: 2),

        // Time
        Text(
          time,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFBFDBFE),
          ),
        ),

        // const SizedBox(height: 4),
        SizedBox(
          width: 44,
          height: 44,
          child: Image.network(
            _getWeatherIconUrl(weather.weatherIcon ?? ''),
            width: 44,
            height: 44,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Icon(
                Icons.cloud,
                size: 44,
                color: Colors.white70,
              );
            },
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.cloud,
              size: 44,
              color: Colors.white,
            ),
          ),
        ),
        // const SizedBox(height: 4),
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

String _getWeatherIconUrl(String icon) {
  final iconUrl = 'https://openweathermap.org/img/wn/$icon@2x.png';
  return iconUrl;
}
