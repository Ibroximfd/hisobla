import 'package:hisobla/features/domain/repositories/budget_repository.dart';

class DeleteAllExpensesUseCase {
  final BudgetRepository repository;

  DeleteAllExpensesUseCase(this.repository);

  Future<void> call() async {
    return await repository.deleteAllExpenses();
  }
}
