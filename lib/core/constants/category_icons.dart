import 'package:flutter/material.dart';

abstract final class CategoryIcons {
  static const Map<String, IconData> catalog = {
    'work': Icons.work_outline,
    'study': Icons.school_outlined,
    'health': Icons.favorite_border,
    'home': Icons.home_outlined,
    'sport': Icons.fitness_center,
    'creative': Icons.brush_outlined,
    'social': Icons.people_outline,
    'finance': Icons.savings_outlined,
    'chores': Icons.checklist_outlined,
    'rest': Icons.self_improvement,
    'travel': Icons.flight_takeoff,
    'other': Icons.label_outline,
  };

  static const String defaultKey = 'other';

  static IconData resolve(String key) => catalog[key] ?? catalog[defaultKey]!;
}
