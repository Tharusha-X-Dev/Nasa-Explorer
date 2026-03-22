import 'package:flutter/material.dart';

class SectionHeadingWidget extends StatelessWidget {
  final String text;
  final double fontSize;

  const SectionHeadingWidget({
    required this.text,
    this.fontSize = 22,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
    );
  }
}
