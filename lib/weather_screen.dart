import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wheatherapp/additional_item.dart';
import 'package:wheatherapp/hourly_forcast_item.dart';
import 'package:wheatherapp/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // double temp = 0;
  // bool isLoading = false;
  @override
  void initState() {
    super.initState();
    // Fetch the current weather when the screen is initialized
    getCurrentWeather();
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'Kurukshetra'; // You can change this to any city you want

      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openweatherApiKey',
        ),
      );

      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An expected error occured';
      }

      // temp = data['list'][0]['main']['temp'];
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Action for settings button
              setState(() {
                // Trigger a rebuild to fetch new weather data
                getCurrentWeather();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator.adaptive());
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          final data = snapshot.data!;

          final currentWeather = data['list'][0];
          final currentTemp = currentWeather['main']['temp'];
          final currentsky = currentWeather['weather'][0]['main'];
          final currentpressure = currentWeather['main']['pressure'];
          final windSpeed = currentWeather['wind']['speed'];
          final humidity = currentWeather['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(16.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp K',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                currentsky == 'Clouds' || currentsky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,

                                size: 64,
                              ),
                              const SizedBox(height: 20),
                              Text(currentsky, style: TextStyle(fontSize: 20)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // weather details
                const SizedBox(height: 8),

                Text(
                  'Hourly Forcast',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // SingleChildScrollView(
                //   scrollDirection: Axis.horizontal,
                //   child: Row(
                //     // mainAxisAlignment: MainAxisAlignment.spaceAround,
                //     children: [
                //       for (int i = 0; i < 5; i++)
                //         HourlyForcastItem(
                //           time: data['list'][i+1]['dt_txt'].substring(11, 16),
                //           icon: data['list'][i+1]['weather'][0]['main'] == 'Clouds' || 
                //                 data['list'][i+1]['weather'][0]['main'] == 'Rain'
                //                 ? Icons.cloud
                //                 : Icons.sunny,
                //           temperature: data['list'][i+1]['main']['temp'].toString(),
                //         ),
                     
                //     ],
                //   ),
                // ),

              SizedBox(
                height: 120,
                width: double.infinity,

                child: ListView.builder(
                  itemCount: 5,
                  scrollDirection: Axis.horizontal,
                 itemBuilder: (context, index) {
                   return HourlyForcastItem(
                     time: data['list'][index + 1]['dt_txt'].substring(11, 16),
                     icon: data['list'][index + 1]['weather'][0]['main'] == 'Clouds' ||
                           data['list'][index + 1]['weather'][0]['main'] == 'Rain'
                           ? Icons.cloud
                           : Icons.sunny,
                     temperature: data['list'][index + 1]['main']['temp'].toString(),
                   );
                 },
                ),
              ),

                //additional details
                const SizedBox(height: 20),
                Text(
                  'Additional Details',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalItem(
                      icon: Icons.water_drop,
                      title: 'Humidity',
                      value: humidity.toString(),
                    ),
                    AdditionalItem(
                      icon: Icons.air,
                      title: 'Wind Speed',
                      value: windSpeed.toString(),
                    ),
                    AdditionalItem(
                      icon: Icons.beach_access,
                      title: 'Pressure',
                      value: currentpressure.toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
