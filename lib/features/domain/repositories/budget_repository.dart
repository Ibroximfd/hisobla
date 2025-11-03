import 'package:hisobla/features/domain/entities/budget.dart';
import 'package:hisobla/features/domain/entities/expense.dart';

abstract class BudgetRepository {
  Future<Budget> getBudget();
  Future<void> setBudget(double amount);
  Future<void> addExpense(double amount, String description);
  Future<List<Expense>> getExpenses();
}
