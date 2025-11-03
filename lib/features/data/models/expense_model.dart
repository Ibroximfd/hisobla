import 'package:hisobla/features/domain/entities/expense.dart';

class ExpenseModel {
  int id;
  double amount;
  String description;
  DateTime date;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
  });

  ExpenseModel.fromEntity(Expense expense)
    : id = expense.id,
      amount = expense.amount,
      description = expense.description,
      date = expense.date;

  Expense toEntity() {
    return Expense(
      id: id,
      amount: amount,
      description: description,
      date: date,
    );
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'description': description,
    'date': date.toIso8601String(),
  };
}

class BudgetModel {
  int id;
  double totalBudget;
  double remainingBudget;

  BudgetModel({
    required this.id,
    required this.totalBudget,
    required this.remainingBudget,
  });

  BudgetModel.create({required this.totalBudget, required this.remainingBudget})
    : id = 1;

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] ?? 1,
      totalBudget: (json['totalBudget'] ?? 0).toDouble(),
      remainingBudget: (json['remainingBudget'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'totalBudget': totalBudget,
    'remainingBudget': remainingBudget,
  };
}
