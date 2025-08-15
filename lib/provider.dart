import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';

class weatherProvider extends ChangeNotifier{
   Future<Map<String, dynamic>>? _weather;
  late List<Placemark> _cities;
  String _loaction = "";
  double _lat = 0;
  double _lon = 0;
  String _cityName = "";

  Future<Map<String, dynamic>>? get weather=> _weather;
  List<Placemark> get cities=>_cities;
  String get loaction => _loaction;
  double get lat => _lat;
  double get lon => _lon;
  String get cityName => _cityName;

  Future<bool> getLoaction() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      _loaction = "permission denied";
      return false;
    } else {
      Position position = await Geolocator.getCurrentPosition();
      _lat = position.latitude;
      _lon = position.longitude;
      _cities = await placemarkFromCoordinates(_lat, _lon);
      _cityName = cities[0].locality!;
      notifyListeners();
      return true;
    }
  }

  Future<Map<String, dynamic>> getCurrentCityWeather({
    required double latt,
    required double lonn,
  }) async {
    try {
      final result = await http.get(
        Uri.parse(
          "http://api.openweathermap.org/data/2.5/forecast?lat=$latt&lon=$lonn&appid=$openWeatherApiKey",
        ),
      );
      final data = jsonDecode(result.body);
      if (data['cod'] != '200') {
        throw ("an unexpected error occur");
      }
      _weather=null;
      _weather= Future.value(data) ;
      notifyListeners();
      return data;
    } catch (e) {
      notifyListeners();
      throw (e.toString());
    }
  }

  Future<Map<String, dynamic>> refreshWeather({
    required double latt,
    required double lonn,
  }) async {
    try {
      _cities = await placemarkFromCoordinates(_lat, _lon);
      _cityName = cities[0].locality!;
      final result = await http.get(
        Uri.parse(
          "http://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$openWeatherApiKey",
        ),
      );
      final data = jsonDecode(result.body);
      if (data['cod'] != '200') {
        throw ("an unexpected error occur");
      }
      _weather=null;
      _weather= Future.value(data);
      notifyListeners();
      return data;
    } catch (e) {
      notifyListeners();
      throw (e.toString());
    }
  }



  Future<Map<String, dynamic>> getSearchCityWeather({
    required String city,
  }) async {
    try {


      final result = await http.get(
        Uri.parse(
          "http://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$openWeatherApiKey",
        ),
      );
      final data = jsonDecode(result.body);
      if (data['cod'] != '200') {
        throw ("an unexpected error occur");
      }

      _cityName = city;
      _weather=null;
      _weather= Future.value(data);
      notifyListeners();
      return data;
    } catch (e) {
      notifyListeners();
      throw (e.toString());
    }
  }
}