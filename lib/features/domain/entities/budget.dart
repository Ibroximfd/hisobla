import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final double totalBudget;
  final double remainingBudget;

  const Budget({required this.totalBudget, required this.remainingBudget});

  @override
  List<Object?> get props => [totalBudget, remainingBudget];
}
