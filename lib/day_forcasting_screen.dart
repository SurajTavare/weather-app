import 'dart:ui';

import 'package:flutter/material.dart';

class DaysForcasting extends StatelessWidget {
  final temp;
  final currentWeather;
  final day;

  const DaysForcasting({
    super.key,
    required this.temp,
    required this.currentWeather,
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: EdgeInsets.all(5),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    day,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow.shade300,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "${temp.toStringAsFixed(2)} °C",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: Colors.grey.shade200),
                    maxLines: 1,
                  ),
                  SizedBox(height: 10),
                  Icon(
                    currentWeather == 'Clouds' || currentWeather == 'Rain'
                        ? Icons.cloud
                        : Icons.sunny,
                    size: 40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "$currentWeather",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: currentWeather == "Clouds" || currentWeather == "Rain" ? Colors.blue : Colors.orange.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
