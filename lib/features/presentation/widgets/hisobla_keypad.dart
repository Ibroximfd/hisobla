import 'package:flutter/material.dart';
import 'package:hisobla/features/presentation/widgets/hisobla_expense_fab.dart';

class CalculatorKeypad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onClearPressed;
  final VoidCallback onDonePressed;

  const CalculatorKeypad({
    super.key,
    required this.onNumberPressed,
    required this.onClearPressed,
    required this.onDonePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 7 8 9
          _buildRow(['7', '8', '9']),
          // 4 5 6
          _buildRow(['4', '5', '6']),
          // 1 2 3
          _buildRow(['1', '2', '3']),
          // 000 0 O'chirish
          Expanded(
            child: Row(
              children: [
                _buildButton('000'),
                _buildButton('0'),
                _buildClearButton(), // Katta, qulay
              ],
            ),
          ),
          const SizedBox(height: 12),
          // TAYYOR - Katta, markaziy
          _buildDoneButton(),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> texts) {
    return Expanded(
      child: Row(children: texts.map((t) => _buildButton(t)).toList()),
    );
  }

  Widget _buildButton(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          elevation: 2,
          child: InkWell(
            onTap: () => onNumberPressed(text),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: text == '000' ? 22 : 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: Colors.orange.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          elevation: 3,
          child: InkWell(
            onTap: onClearPressed,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.backspace_outlined,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoneButton() {
    return Row(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            height: 68,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Material(
              color: Colors.green,
              borderRadius: BorderRadius.circular(24),
              elevation: 6,
              child: InkWell(
                onTap: onDonePressed,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [Colors.green.shade600, Colors.green.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Tayyor',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        ExpenseListFab(),
      ],
    );
  }
}
