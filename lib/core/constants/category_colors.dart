import 'package:flutter/material.dart';

abstract final class CategoryColors {
  static const List<Color> palette = [
    Color(0xFF7C5CFC),
    Color(0xFFE05252),
    Color(0xFFE0A027),
    Color(0xFF2FA86C),
    Color(0xFF2F9AC2),
    Color(0xFF2F6FE0),
    Color(0xFFB05CE0),
    Color(0xFFE0578F),
    Color(0xFF6C7A89),
    Color(0xFF8C6A4E),
    Color(0xFF4EA88C),
    Color(0xFFC2792F),
  ];

  static Color get defaultColor => palette.first;
}
