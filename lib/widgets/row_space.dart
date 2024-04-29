import 'package:flutter/material.dart';

class RowSpace extends StatelessWidget {
  final Widget lWidget;
  final List<Widget> rWidget;
  final double vertical;

  const RowSpace(
      {super.key,
      required this.lWidget,
      required this.rWidget,
      this.vertical = 10});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: vertical),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [lWidget, Row(children: rWidget)]));
  }
}
