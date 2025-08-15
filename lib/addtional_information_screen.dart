import 'package:flutter/material.dart';

class AdditionInfo extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;

  const AdditionInfo({
    required this.label,
    required this.icon,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(width: 1, color: Colors.green),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Icon(icon, size: 30),
              SizedBox(height: 15),
              Text(label, style: TextStyle(fontSize: 15)),
              SizedBox(height: 15),
              Text(
                value,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
