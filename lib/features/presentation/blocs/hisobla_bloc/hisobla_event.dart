import 'package:equatable/equatable.dart';

abstract class BudgetEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBudgetEvent extends BudgetEvent {}

class SetBudgetEvent extends BudgetEvent {
  final double amount;
  SetBudgetEvent(this.amount);

  @override
  List<Object?> get props => [amount];
}

class AddExpenseEvent extends BudgetEvent {
  final double amount;
  final String description;

  AddExpenseEvent(this.amount, this.description);

  @override
  List<Object?> get props => [amount, description];
}

class DeleteAllExpensesEvent extends BudgetEvent {}
