import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/provider.dart';
import 'package:weather_app/weather_screen.dart';

void main() {
  runApp(
      ChangeNotifierProvider(
          create: (context)=> weatherProvider(),
          child: MyApp()));
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: weatherScreen(),
    );
  }
}
