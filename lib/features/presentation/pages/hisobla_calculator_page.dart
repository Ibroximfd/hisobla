import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobla/features/presentation/blocs/hisobla_bloc/hisobla_bloc.dart';
import 'package:hisobla/features/presentation/blocs/hisobla_bloc/hisobla_event.dart';
import 'package:hisobla/features/presentation/blocs/hisobla_bloc/hisobla_state.dart';
import 'package:hisobla/features/presentation/widgets/hisobla_budget_display.dart';
import 'package:hisobla/features/presentation/widgets/hisobla_expense_fab.dart';
import 'package:hisobla/features/presentation/widgets/hisobla_keypad.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _displayValue = '0';
  String _description = '';
  bool _isEditingBudget = false;
  final TextEditingController _descriptionController = TextEditingController();

  void _onNumberPressed(String number) {
    setState(() {
      if (_displayValue == '0') {
        _displayValue = number;
      } else {
        _displayValue += number;
      }
    });
  }

  void _onClearPressed() {
    setState(() {
      _displayValue = '0';
      _description = '';
      _descriptionController.clear();
    });
  }

  void _onDonePressed() {
    final amount = double.tryParse(_displayValue);
    if (amount == null || amount <= 0) return;

    final bloc = context.read<BudgetBloc>();

    if (_isEditingBudget) {
      bloc.add(SetBudgetEvent(amount));
      setState(() {
        _isEditingBudget = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade600,
          content: const Text('Xarajat qo\'shildi'),
          duration: const Duration(seconds: 2),
          animation: CurvedAnimation(
            parent: AnimationController(
              vsync: Scaffold.of(context),
              duration: const Duration(milliseconds: 400),
            ),
            curve: Curves.easeOutBack,
          ),
        ),
      );
    } else {
      bloc.add(AddExpenseEvent(amount, _description));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Xarajat qo\'shildi')));
    }

    _onClearPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: BlocBuilder<BudgetBloc, BudgetState>(
          builder: (context, state) {
            if (state is BudgetLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BudgetLoaded) {
              return Column(
                children: [
                  /// === HEADER / BUDGET ===
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(28),
                      ),
                    ),
                    child: BudgetDisplay(
                      budget: state.budget,
                      displayValue: _displayValue,
                      description: _description,
                      isEditingBudget: _isEditingBudget,
                      onEditBudget: () {
                        setState(() {
                          _isEditingBudget = true;
                          _displayValue = '0';
                        });
                      },
                      descriptionController: _descriptionController,
                      onDescriptionChanged: (value) {
                        setState(() {
                          _description = value;
                        });
                      },
                    ),
                  ),

                  /// === KEYPAD AREA ===
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(),
                      child: CalculatorKeypad(
                        onNumberPressed: _onNumberPressed,
                        onClearPressed: _onClearPressed,
                        onDonePressed: _onDonePressed,
                      ),
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text('Xatolik yuz berdi'));
          },
        ),
      ),
      floatingActionButton: const ExpenseListFab(),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
