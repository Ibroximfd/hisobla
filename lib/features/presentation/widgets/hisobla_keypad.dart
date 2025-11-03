import 'package:flutter/material.dart';

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
          Expanded(
            child: Row(
              children: [
                _buildButton('7'),
                _buildButton('8'),
                _buildButton('9'),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildButton('4'),
                _buildButton('5'),
                _buildButton('6'),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildButton('1'),
                _buildButton('2'),
                _buildButton('3'),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildButton('000'),
                _buildButton('0'),
                _buildSpecialButton(
                  'O\'chirish',
                  Icons.backspace_outlined,
                  Colors.orange,
                  onClearPressed,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildDoneButton(),
        ],
      ),
    );
  }

  Widget _buildButton(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => onNumberPressed(text),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 28,
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

  Widget _buildSpecialButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Material(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3), width: 1.5),
              ),
              child: Center(child: Icon(icon, color: color, size: 28)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoneButton() {
    return Container(
      width: double.infinity,
      height: 60,

      margin: const EdgeInsets.only(left: 6, right: 80, top: 16),
      child: Material(
        color: Colors.green,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onDonePressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Hisoblash',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
