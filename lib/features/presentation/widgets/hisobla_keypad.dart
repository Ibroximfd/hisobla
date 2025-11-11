import 'package:flutter/material.dart';
import 'package:hisobla/features/presentation/widgets/hisobla_expense_fab.dart';
import 'package:hisobla/features/presentation/widgets/voice_expense_button.dart';

class CalculatorKeypad extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onClearPressed;
  final VoidCallback onDonePressed;
  final double availableHeight;

  const CalculatorKeypad({
    super.key,
    required this.onNumberPressed,
    required this.onClearPressed,
    required this.onDonePressed,
    required this.availableHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Ekran balandligiga qarab padding va tugma o'lchamlarini moslashtirish
    final isVeryCompact = availableHeight < 280;
    final isCompact = availableHeight >= 280 && availableHeight < 350;

    final horizontalPadding = isVeryCompact ? 8.0 : (isCompact ? 12.0 : 16.0);
    final verticalPadding = isVeryCompact ? 4.0 : (isCompact ? 8.0 : 12.0);
    final buttonPadding = isVeryCompact ? 3.0 : (isCompact ? 4.0 : 6.0);
    final doneButtonHeight = isVeryCompact ? 52.0 : (isCompact ? 60.0 : 68.0);
    final fabWidth = isVeryCompact ? 56.0 : (isCompact ? 62.0 : 68.0);
    final bottomSpacing = isVeryCompact ? 6.0 : (isCompact ? 8.0 : 12.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        children: [
          // 7 8 9
          _buildRow(['7', '8', '9'], buttonPadding, isVeryCompact),
          // 4 5 6
          _buildRow(['4', '5', '6'], buttonPadding, isVeryCompact),
          // 1 2 3
          _buildRow(['1', '2', '3'], buttonPadding, isVeryCompact),
          // 000 0 O'chirish
          Expanded(
            child: Row(
              children: [
                _buildButton('000', buttonPadding, isVeryCompact),
                _buildButton('0', buttonPadding, isVeryCompact),
                _buildClearButton(buttonPadding, isVeryCompact),
              ],
            ),
          ),
          SizedBox(height: bottomSpacing),
          // TAYYOR - Katta, markaziy
          _buildDoneButton(
            doneButtonHeight,
            fabWidth,
            buttonPadding,
            isVeryCompact,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> texts, double padding, bool isVeryCompact) {
    return Expanded(
      child: Row(
        children: texts
            .map((t) => _buildButton(t, padding, isVeryCompact))
            .toList(),
      ),
    );
  }

  Widget _buildButton(String text, double padding, bool isVeryCompact) {
    final fontSize = isVeryCompact
        ? (text == '000' ? 18.0 : 24.0)
        : (text == '000' ? 22.0 : 30.0);

    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isVeryCompact ? 16 : 20),
          elevation: 2,
          child: InkWell(
            onTap: () => onNumberPressed(text),
            borderRadius: BorderRadius.circular(isVeryCompact ? 16 : 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isVeryCompact ? 16 : 20),
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
                    fontSize: fontSize,
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

  Widget _buildClearButton(double padding, bool isVeryCompact) {
    final iconSize = isVeryCompact ? 26.0 : 32.0;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Material(
          color: Colors.orange.withOpacity(0.12),
          borderRadius: BorderRadius.circular(isVeryCompact ? 16 : 20),
          elevation: 3,
          child: InkWell(
            onTap: onClearPressed,
            borderRadius: BorderRadius.circular(isVeryCompact ? 16 : 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isVeryCompact ? 16 : 20),
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
              child: Center(
                child: Icon(
                  Icons.backspace_outlined,
                  color: Colors.orange,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoneButton(
    double height,
    double fabWidth,
    double padding,
    bool isVeryCompact,
  ) {
    final fontSize = isVeryCompact ? 18.0 : 22.0;
    final borderRadius = isVeryCompact ? 20.0 : 24.0;
    final voiceButtonWidth = isVeryCompact ? 56.0 : 68.0;

    return Row(
      children: [
        VoiceExpenseButton(
          height: height,
          width: voiceButtonWidth,
          isCompact: isVeryCompact,
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            height: height,
            margin: EdgeInsets.symmetric(horizontal: padding),
            child: Material(
              color: Colors.green,
              borderRadius: BorderRadius.circular(borderRadius),
              elevation: 6,
              child: InkWell(
                onTap: onDonePressed,
                borderRadius: BorderRadius.circular(borderRadius),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
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
                  child: Center(
                    child: Text(
                      'Tayyor',
                      style: TextStyle(
                        fontSize: fontSize,
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
        ExpenseListFab(
          height: height,
          width: fabWidth,
          isCompact: isVeryCompact,
        ),
      ],
    );
  }
}
