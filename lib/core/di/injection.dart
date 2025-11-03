import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hisobla/features/data/datasources/hisobla_datasource.dart';
import 'package:hisobla/features/data/repositories/hisobla_repo_impl.dart';
import 'package:hisobla/features/domain/repositories/budget_repository.dart';
import 'package:hisobla/features/domain/usecases/add_expense_usecase.dart';
import 'package:hisobla/features/domain/usecases/get_budget_usecase.dart';
import 'package:hisobla/features/domain/usecases/get_expense_usecase.dart';
import 'package:hisobla/features/domain/usecases/set_budget_usecase.dart';
import 'package:hisobla/features/presentation/blocs/hisobla_bloc/hisobla_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  // Data sources
  getIt.registerLazySingleton<BudgetLocalDataSource>(
    () => BudgetLocalDataSourceImpl(prefs),
  );

  // Repositories
  getIt.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => GetBudgetUseCase(getIt()));
  getIt.registerLazySingleton(() => SetBudgetUseCase(getIt()));
  getIt.registerLazySingleton(() => AddExpenseUseCase(getIt()));
  getIt.registerLazySingleton(() => GetExpensesUseCase(getIt()));

  // Bloc
  getIt.registerFactory(
    () => BudgetBloc(
      getBudget: getIt(),
      setBudget: getIt(),
      addExpense: getIt(),
      getExpenses: getIt(),
    ),
  );
}
