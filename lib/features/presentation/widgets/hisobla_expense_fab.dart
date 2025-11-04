import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisobla/features/presentation/blocs/hisobla_bloc/hisobla_bloc.dart';
import 'package:hisobla/features/presentation/blocs/hisobla_bloc/hisobla_event.dart';
import 'package:hisobla/features/presentation/blocs/hisobla_bloc/hisobla_state.dart';
import 'package:intl/intl.dart';

class ExpenseListFab extends StatelessWidget {
  final double height;
  final double width;
  final bool isCompact;

  const ExpenseListFab({
    super.key,
    this.height = 60,
    this.width = 68,
    this.isCompact = false,
  });

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            const Text('Ishonchingiz komilmi?'),
          ],
        ),
        content: const Text(
          'Barcha xarajatlar tarixi o\'chiriladi va byudjet qoldig\'i asl holatiga qaytariladi.\n\n'
          'Bu amalni bekor qilib bo\'lmaydi!',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Bekor qilish',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
              context.read<BudgetBloc>().add(DeleteAllExpensesEvent());

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Barcha xarajatlar o\'chirildi'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Ha, o\'chirish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = isCompact ? 24.0 : 28.0;
    final borderRadius = isCompact ? 10.0 : 12.0;

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Xarajatlar tarixi',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _showDeleteConfirmationDialog(context),
                                icon: const Icon(Icons.delete_sweep),
                                color: Colors.red,
                                tooltip: 'Barchasini o\'chirish',
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Divider(),

                    // Expense List
                    Expanded(
                      child: BlocBuilder<BudgetBloc, BudgetState>(
                        builder: (context, state) {
                          if (state is BudgetLoaded) {
                            if (state.expenses.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: 80,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Hali xarajat yo\'q',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final totalExpense = state.expenses.fold<double>(
                              0,
                              (sum, expense) => sum + expense.amount,
                            );

                            return ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: state.expenses.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  // Summary Card
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.red.shade400,
                                          Colors.red.shade600,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Jami xarajat',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(
                                                  0.9,
                                                ),
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${_formatCurrency(totalExpense)} so\'m',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Icon(
                                          Icons.trending_down,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                final expense = state.expenses[index - 1];
                                final dateFormat = DateFormat(
                                  'dd.MM.yyyy HH:mm',
                                );

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.remove_circle_outline,
                                        color: Colors.red.shade400,
                                        size: 28,
                                      ),
                                    ),
                                    title: Text(
                                      expense.description.isEmpty
                                          ? 'Izoh yo\'q'
                                          : expense.description,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Text(
                                      dateFormat.format(expense.date),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    trailing: Text(
                                      '-${_formatCurrency(expense.amount)} so\'m',
                                      style: TextStyle(
                                        color: Colors.red.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.blue.shade600,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(Icons.history, size: iconSize, color: Colors.white),
      ),
    );
  }
}
