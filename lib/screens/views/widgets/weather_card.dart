import 'package:flutter/material.dart';
import 'package:icon_forest/iconoir.dart';
import 'package:intl/intl.dart';
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/screens/views/home_screen.dart';
import 'package:weather/weather.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  double lat = 55.0111;

  double lon = 15.0569;

  String cityName = 'Kongens Lyngby';

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
            final Temp = weather?.temperature?.celsius?.toInt();
            final date = weather?.date;
            final formattedDate = DateFormat.MMMEd().format(date!);
            final wind = weather?.windSpeed;
            final humidity = weather?.humidity;
            final cloud = weather?.cloudiness;
            // double temp=w.temperature.celcius;
            // double celsius = snapshot.temperature.celsius;
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(12),
                color: Colors.lightBlueAccent,
              ),
              child: Column(
                children: [
                  Text('location'),
                  Text(
                    '$Temp°',
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                  Text('$formattedDate'),
                  Divider(
                    color: Colors.black,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.wind_power_sharp),
                          Text('$wind'),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.water_drop_rounded),
                          Text('$humidity'),
                        ],
                      ),
                      Column(
                        children: [
                          Iconoir(Iconoir.cloud),
                          // Icon(Icons.clou),
                          Text('$cloud'),
                        ],
                      ),
                    ],
                  ),
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
