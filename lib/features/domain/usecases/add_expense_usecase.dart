import 'package:hisobla/features/domain/repositories/budget_repository.dart';

class AddExpenseUseCase {
  final BudgetRepository repository;

  AddExpenseUseCase(this.repository);

  Future<void> call(double amount, String description) async {
    return await repository.addExpense(amount, description);
  }
}
