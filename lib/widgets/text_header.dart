import 'package:flutter/material.dart';

class TextHeader extends StatelessWidget {
  final String text;
  final Color color;
  const TextHeader({super.key, required this.text, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color,
        ));
  }
}
