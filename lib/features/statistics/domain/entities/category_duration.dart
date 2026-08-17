import 'package:equatable/equatable.dart';

/// Total tracked time for a single category within a statistics period.
class CategoryDuration extends Equatable {
  const CategoryDuration({
    required this.categoryId,
    required this.totalDurationSeconds,
  });

  final int categoryId;
  final int totalDurationSeconds;

  @override
  List<Object?> get props => [categoryId, totalDurationSeconds];
}
