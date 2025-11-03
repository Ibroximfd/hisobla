import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobla/features/domain/usecases/add_expense_usecase.dart';
import 'package:hisobla/features/domain/usecases/get_budget_usecase.dart';
import 'package:hisobla/features/domain/usecases/get_expense_usecase.dart';
import 'package:hisobla/features/domain/usecases/set_budget_usecase.dart';
import 'package:hisobla/features/presentation/blocs/hisobla_bloc/hisobla_event.dart';
import 'package:hisobla/features/presentation/blocs/hisobla_bloc/hisobla_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final GetBudgetUseCase getBudget;
  final SetBudgetUseCase setBudget;
  final AddExpenseUseCase addExpense;
  final GetExpensesUseCase getExpenses;

  BudgetBloc({
    required this.getBudget,
    required this.setBudget,
    required this.addExpense,
    required this.getExpenses,
  }) : super(BudgetInitial()) {
    on<LoadBudgetEvent>(_onLoadBudget);
    on<SetBudgetEvent>(_onSetBudget);
    on<AddExpenseEvent>(_onAddExpense);
  }

  Future<void> _onLoadBudget(
    LoadBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final budget = await getBudget();
      final expenses = await getExpenses();
      emit(BudgetLoaded(budget, expenses));
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onSetBudget(
    SetBudgetEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await setBudget(event.amount);
      add(LoadBudgetEvent());
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await addExpense(event.amount, event.description);
      add(LoadBudgetEvent());
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }
}
