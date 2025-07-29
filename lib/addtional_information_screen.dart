
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
    return Column(
      children: [
        Icon(icon, size: 45),
        SizedBox(height: 15),
        Text(label,
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        SizedBox(height: 15),
        Text(value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
