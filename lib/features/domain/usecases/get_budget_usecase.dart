import 'package:hisobla/features/domain/entities/budget.dart';
import 'package:hisobla/features/domain/repositories/budget_repository.dart';

class GetBudgetUseCase {
  final BudgetRepository repository;

  GetBudgetUseCase(this.repository);

  Future<Budget> call() async {
    return await repository.getBudget();
  }
}
