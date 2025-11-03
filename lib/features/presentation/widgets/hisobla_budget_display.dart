import 'package:flutter/material.dart';
import 'package:hisobla/features/presentation/pages/settings_page.dart';
import '../../domain/entities/budget.dart';

class BudgetDisplay extends StatelessWidget {
  final Budget budget;
  final String displayValue;
  final String description;
  final bool isEditingBudget;
  final VoidCallback onEditBudget;
  final TextEditingController descriptionController;
  final ValueChanged<String> onDescriptionChanged;

  const BudgetDisplay({
    super.key,
    required this.budget,
    required this.displayValue,
    required this.description,
    required this.isEditingBudget,
    required this.onEditBudget,
    required this.descriptionController,
    required this.onDescriptionChanged,
  });

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxHeight < 400;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade600, Colors.blue.shade800],
            ),
          ),
          child: SafeArea(
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 400),
              crossFadeState: isEditingBudget
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: _buildNormalMode(isSmallScreen, context),
              secondChild: _buildEditMode(isSmallScreen),
              layoutBuilder: (topChild, topKey, bottomChild, bottomKey) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(key: bottomKey, child: bottomChild),
                    Positioned.fill(key: topKey, child: topChild),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // NORMAL REJIM
  Widget _buildNormalMode(bool isSmallScreen, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Oylik byudjet + edit
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Oylik byudjet',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_formatCurrency(budget.totalBudget)} so\'m',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 26 : 32,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _buildEditButton(isSmallScreen, Icons.edit),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
              icon: Icon(Icons.settings, color: Colors.white),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Qoldiq
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qoldiq',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              Text(
                '${_formatCurrency(budget.remainingBudget)} so\'m',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 16 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Izoh
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Izoh',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Nimaga sarflandi?',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: onDescriptionChanged,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),

        // Summa kartasi
        _buildValueCard(isSmallScreen, 'Summa'),
      ],
    );
  }

  // EDIT REJIM — MARKAZDA KATTA KARTA
  Widget _buildEditMode(bool isSmallScreen) {
    return Column(
      children: [
        // Oylik byudjet + close
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Oylik byudjet',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_formatCurrency(budget.totalBudget)} so\'m',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isSmallScreen ? 26 : 32,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _buildEditButton(isSmallScreen, Icons.close),
          ],
        ),

        const Spacer(), // Katta kartani markazga suradi
        // KATTA YANGI BYUDJET KARTASI
        AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Yangi byudjet',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$displayValue so\'m',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: isSmallScreen ? 40 : 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const Spacer(),
      ],
    );
  }

  // Tugma (edit/close)
  Widget _buildEditButton(bool isSmallScreen, IconData icon) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: IconButton(
        key: ValueKey(icon),
        onPressed: onEditBudget,
        icon: Icon(icon, color: Colors.white),
        iconSize: isSmallScreen ? 24 : 28,
      ),
    );
  }

  // Summa kartasi (normal rejim)
  Widget _buildValueCard(bool isSmallScreen, String label) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$displayValue so\'m',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: isSmallScreen ? 28 : 36,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
