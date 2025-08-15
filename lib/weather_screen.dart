import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/secrets.dart';
import "addtional_information_screen.dart";
import 'day_forcasting_screen.dart';
import 'hrs_forecast_disply_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class weatherScreen extends StatefulWidget {
  const weatherScreen({super.key});

  @override
  State<weatherScreen> createState() => _weatherScreenState();
}

class _weatherScreenState extends State<weatherScreen> {


  TextEditingController cityController = TextEditingController();
  late Future<Map<String, dynamic>> weather;
  late List<Placemark> cities;
  String loaction = "";
  double lat = 0;
  double lon = 0;
  String cityName = "";

  @override
  void initState() {
    super.initState();
    getLoaction();
    weather=getCurrentCityWeather(latt: lat, lonn: lon);

  }

  Future<bool> getLoaction() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      loaction = "permission denied";
      return false;
    } else {
      Position position = await Geolocator.getCurrentPosition();
      lat = position.latitude;
      lon = position.longitude;
      cities = await placemarkFromCoordinates(lat, lon);
      setState(() {
        cityName = cities[0].locality!;
      });
      print(cities);
      return true;
    }
  }

  Future<Map<String, dynamic>> getCurrentCityWeather({
    required double latt,
    required double lonn,
  }) async {
    print("getCurrentCityWeather");
    try {
      final result = await http.get(
        Uri.parse(
          "http://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$openWeatherApiKey",
        ),
      );
      final data = jsonDecode(result.body);
      if (data['cod'] != '200') {
        throw ("an unexpected error occur");
      }
      return data;
    } catch (e) {
      throw (e.toString());
    }
  }

  Future<Map<String, dynamic>> refreshWeather({
    required double latt,
    required double lonn,
  }) async {
    print("refesh");
    try {
      cities = await placemarkFromCoordinates(lat, lon);
      setState(() {
        cityName = cities[0].locality!;
      });
      final result = await http.get(
        Uri.parse(
          "http://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$openWeatherApiKey",
        ),
      );
      final data = jsonDecode(result.body);

      if (data['cod'] != '200') {
        throw ("an unexpected error occur");
      }
      return data;
    } catch (e) {
      throw (e.toString());
    }
  }

  Future<Map<String, dynamic>> getSearchCityWeather({
    required String city,
  }) async {
    try {
      setState(() {
        cityName = city;
      });
      final result = await http.get(
        Uri.parse(
          "http://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$openWeatherApiKey",
        ),
      );
      final data = jsonDecode(result.body);
      if (data['cod'] != '200') {
        throw ("an unexpected error occur");
      }
      print(data);
      return data;
    } catch (e) {
      throw (e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Weather App",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                weather = refreshWeather(latt: lat, lonn:lon);
              });
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: weather,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator.adaptive());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            final data = snapshot.data!;

            Map<String, List<dynamic>> dailyData = {};
            for (var entry in data['list']) {
              final date = DateTime.parse(entry['dt_txt']).toLocal();
              final dayKey = "${date.year}-${date.month}-${date.day}";

              if (!dailyData.containsKey(dayKey)) {
                dailyData[dayKey] = [];
              }
              dailyData[dayKey]!.add(entry);
            }

            List<Map<String, dynamic>> fiveDayForecast = [];
            dailyData.forEach((day, entries) {
              if (fiveDayForecast.length < 5) {
                final middayEntry = entries.firstWhere(
                  (entry) => DateTime.parse(entry['dt_txt']).hour == 12,
                  orElse: () => entries.first,
                );
                fiveDayForecast.add(middayEntry);
              }
            });
            final humidity = data['list'][0]['main']['humidity'];
            final windSpeed = data['list'][0]['wind']['speed'];
            final pressure = data['list'][0]['main']['pressure'];

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: cityController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                      ],
                      onSubmitted: (value) {
                        setState(() {
                          weather = getSearchCityWeather(city: value.trim());
                        });
                        cityController.clear();
                      },
                      decoration: InputDecoration(
                        suffixIcon: Icon(Icons.search, size: 25),
                        hintStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        hintText: "Search City",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Center(
                      child: Text(
                        cityName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),

                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: fiveDayForecast.length,
                        itemBuilder: (context, index) {
                          final dayData = fiveDayForecast[index];
                          final time = DateTime.parse(dayData['dt_txt']);
                          final dayName = DateFormat.EEEE().format(
                            time,
                          ); // "Monday", etc.
                          final temp = (dayData['main']['temp'] - 273.15);
                          final weather = dayData['weather'][0]['main'];
                          return DaysForcasting(
                            temp: temp,
                            currentWeather: weather,
                            day: dayName,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Today's Weather Forecast",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 130,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          final time = DateTime.parse(
                            data['list'][index + 1]['dt_txt'],
                          );
                          return hrsForcastDisply(
                            time: DateFormat.j().format(time),
                            icon:
                                data['list'][index + 1]['weather'][0]['main'] ==
                                        "Clouds" ||
                                    data['list'][index +
                                            1]['weather'][0]['main'] ==
                                        "Rain"
                                ? Icons.cloud
                                : Icons.sunny,
                            temp: data['list'][index + 1]['main']['temp']
                                .toString(),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Additional Information",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          AdditionInfo(
                            label: "humidity",
                            icon: Icons.water_drop,
                            value: humidity.toString(),
                          ),
                          AdditionInfo(
                            label: "wind speed",
                            icon: Icons.air,
                            value: "$windSpeed",
                          ),
                          AdditionInfo(
                            label: "Pressure",
                            icon: Icons.beach_access,
                            value: pressure.toString(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
