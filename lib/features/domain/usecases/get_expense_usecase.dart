import 'package:hisobla/features/domain/entities/expense.dart';
import 'package:hisobla/features/domain/repositories/budget_repository.dart';

class GetExpensesUseCase {
  final BudgetRepository repository;

  GetExpensesUseCase(this.repository);

  Future<List<Expense>> call() async {
    return await repository.getExpenses();
  }
}
