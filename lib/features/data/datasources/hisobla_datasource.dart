import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hisobla/features/data/models/expense_model.dart';

abstract class BudgetLocalDataSource {
  Future<BudgetModel> getBudget();
  Future<void> setBudget(double amount);
  Future<void> addExpense(double amount, String description);
  Future<List<ExpenseModel>> getExpenses();
}

class BudgetLocalDataSourceImpl implements BudgetLocalDataSource {
  final SharedPreferences prefs;

  static const _budgetKey = 'budget_data';
  static const _expensesKey = 'expenses_data';

  BudgetLocalDataSourceImpl(this.prefs);

  @override
  Future<BudgetModel> getBudget() async {
    final jsonString = prefs.getString(_budgetKey);

    if (jsonString != null) {
      final jsonMap = jsonDecode(jsonString);
      return BudgetModel.fromJson(jsonMap);
    } else {
      final newBudget = BudgetModel.create(totalBudget: 0, remainingBudget: 0);
      await prefs.setString(_budgetKey, jsonEncode(newBudget.toJson()));
      return newBudget;
    }
  }

  @override
  Future<void> setBudget(double amount) async {
    final newBudget = BudgetModel.create(
      totalBudget: amount,
      remainingBudget: amount,
    );
    await prefs.setString(_budgetKey, jsonEncode(newBudget.toJson()));
  }

  @override
  Future<void> addExpense(double amount, String description) async {
    // 1️⃣ Avval byudjetni olish
    final budget = await getBudget();
    final newRemaining = budget.remainingBudget - amount;

    // 2️⃣ Yangilangan byudjetni yozish
    final updatedBudget = BudgetModel.create(
      totalBudget: budget.totalBudget,
      remainingBudget: newRemaining,
    );
    await prefs.setString(_budgetKey, jsonEncode(updatedBudget.toJson()));

    // 3️⃣ Yangi xarajatni yaratish
    final existingExpenses = await getExpenses();
    final nextId = (existingExpenses.isEmpty)
        ? 1
        : (existingExpenses.map((e) => e.id).reduce((a, b) => a > b ? a : b) +
              1);

    final expense = ExpenseModel(
      id: nextId,
      amount: amount,
      description: description,
      date: DateTime.now(),
    );

    existingExpenses.add(expense);

    // 4️⃣ JSON formatida saqlash
    final encoded = existingExpenses.map((e) => e.toJson()).toList();
    await prefs.setString(_expensesKey, jsonEncode(encoded));
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final jsonString = prefs.getString(_expensesKey);
    if (jsonString == null) return [];

    final List<dynamic> list = jsonDecode(jsonString);
    final result = list
        .map((e) => ExpenseModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }
}
