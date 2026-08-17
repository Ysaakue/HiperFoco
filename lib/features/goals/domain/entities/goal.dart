import 'package:equatable/equatable.dart';

const _unset = Object();

class Goal extends Equatable {
  const Goal({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal copyWith({
    String? title,
    Object? description = _unset,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      description: identical(description, _unset)
          ? this.description
          : description as String?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, description, createdAt, updatedAt];
}
