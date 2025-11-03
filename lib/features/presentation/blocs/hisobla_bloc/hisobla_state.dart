import 'package:equatable/equatable.dart';
import 'package:hisobla/features/domain/entities/budget.dart';
import 'package:hisobla/features/domain/entities/expense.dart';

abstract class BudgetState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final Budget budget;
  final List<Expense> expenses;

  BudgetLoaded(this.budget, this.expenses);

  @override
  List<Object?> get props => [budget, expenses];
}

class BudgetError extends BudgetState {
  final String message;
  BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}
