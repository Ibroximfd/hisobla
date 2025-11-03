import 'package:hisobla/features/domain/repositories/budget_repository.dart';

class SetBudgetUseCase {
  final BudgetRepository repository;

  SetBudgetUseCase(this.repository);

  Future<void> call(double amount) async {
    return await repository.setBudget(amount);
  }
}
