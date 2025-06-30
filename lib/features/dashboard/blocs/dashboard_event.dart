import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  final int? year;
  final int? month;
  final int? day;

  const LoadDashboard({this.year, this.month, this.day});

  @override
  List<Object?> get props => [year, month, day];
}
