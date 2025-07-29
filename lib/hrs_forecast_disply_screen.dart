
import 'package:flutter/material.dart';

class hrsForcastDisply extends StatelessWidget {
  final String time;
  final IconData icon;
  final String temp;

  const hrsForcastDisply({
    required this.time,
    required  this.icon,
    required this.temp,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Container(
        width: 100,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                time, // time for the forecast
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 8), // spacing between icon and text
              Icon(icon,
                  size: 32),
              SizedBox(height: 9), // spacing between icon and text

              Text(
                "${(double.parse(temp)- 273.15).toStringAsFixed(2)} °C", //temperature
                style: TextStyle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
