import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final int id;
  final double amount;
  final String description;
  final DateTime date;

  const Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
  });

  @override
  List<Object?> get props => [id, amount, description, date];
}
