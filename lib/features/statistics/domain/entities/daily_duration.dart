import 'package:equatable/equatable.dart';

/// Total tracked time (across every category) for a single calendar day
/// within a statistics period — one bucket per day in the period, including
/// days with zero tracked time, so a trend chart has a continuous axis.
class DailyDuration extends Equatable {
  const DailyDuration({required this.date, required this.totalDurationSeconds});

  final DateTime date;
  final int totalDurationSeconds;

  @override
  List<Object?> get props => [date, totalDurationSeconds];
}
