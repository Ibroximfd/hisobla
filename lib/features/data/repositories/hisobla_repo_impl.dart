import 'package:hisobla/features/data/datasources/hisobla_datasource.dart';
import 'package:hisobla/features/domain/entities/budget.dart';
import 'package:hisobla/features/domain/entities/expense.dart';
import 'package:hisobla/features/domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetLocalDataSource localDataSource;

  BudgetRepositoryImpl(this.localDataSource);

  @override
  Future<Budget> getBudget() async {
    final model = await localDataSource.getBudget();
    return Budget(
      totalBudget: model.totalBudget,
      remainingBudget: model.remainingBudget,
    );
  }

  @override
  Future<void> setBudget(double amount) async {
    await localDataSource.setBudget(amount);
  }

  @override
  Future<void> addExpense(double amount, String description) async {
    await localDataSource.addExpense(amount, description);
  }

  @override
  Future<List<Expense>> getExpenses() async {
    final models = await localDataSource.getExpenses();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> deleteAllExpenses() async {
    await localDataSource.deleteAllExpenses();
  }
}
