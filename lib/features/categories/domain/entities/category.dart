import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconKey,
    required this.isArchived,
    required this.createdAt,
  });

  final int id;
  final String name;
  final int colorValue;
  final String iconKey;
  final bool isArchived;
  final DateTime createdAt;

  Category copyWith({
    String? name,
    int? colorValue,
    String? iconKey,
    bool? isArchived,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconKey: iconKey ?? this.iconKey,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, colorValue, iconKey, isArchived, createdAt];
}
