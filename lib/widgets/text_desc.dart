import 'package:flutter/material.dart';

class TextDesc extends StatelessWidget {
  final String text;
  final FontWeight fontWeight;
  final Color color;

  const TextDesc({
    super.key,
    required this.text,
    this.fontWeight = FontWeight.normal,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.left,
      style: TextStyle(fontSize: 15, fontWeight: fontWeight, color: color),
    );
  }
}
