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
        // Ekran balandligiga qarab o'lchamlarni aniqlash
        final availableHeight = constraints.maxHeight;
        final isVeryCompact = availableHeight < 200;
        final isCompact = availableHeight >= 200 && availableHeight < 280;

        // Font o'lchamlari
        final titleFontSize = isVeryCompact ? 12.0 : (isCompact ? 14.0 : 16.0);
        final budgetFontSize = isVeryCompact ? 22.0 : (isCompact ? 26.0 : 32.0);
        final labelFontSize = isVeryCompact ? 12.0 : (isCompact ? 14.0 : 16.0);
        final remainingFontSize = isVeryCompact
            ? 14.0
            : (isCompact ? 16.0 : 20.0);
        final displayValueFontSize = isVeryCompact
            ? 32.0
            : (isCompact ? 40.0 : 48.0);

        // Padding va spacing
        final horizontalPadding = isVeryCompact
            ? 12.0
            : (isCompact ? 16.0 : 24.0);
        final verticalSpacing = isVeryCompact ? 8.0 : (isCompact ? 12.0 : 16.0);
        final cardPadding = isVeryCompact ? 10.0 : (isCompact ? 12.0 : 14.0);

        // Border radius
        final borderRadius = isVeryCompact ? 12.0 : (isCompact ? 14.0 : 16.0);

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
              firstChild: _buildNormalMode(
                context,
                titleFontSize,
                budgetFontSize,
                labelFontSize,
                remainingFontSize,
                displayValueFontSize,
                verticalSpacing,
                cardPadding,
                borderRadius,
                isVeryCompact,
              ),
              secondChild: _buildEditMode(
                titleFontSize,
                budgetFontSize,
                displayValueFontSize,
                cardPadding,
                borderRadius,
                isVeryCompact,
              ),
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
  Widget _buildNormalMode(
    BuildContext context,
    double titleFontSize,
    double budgetFontSize,
    double labelFontSize,
    double remainingFontSize,
    double displayValueFontSize,
    double verticalSpacing,
    double cardPadding,
    double borderRadius,
    bool isVeryCompact,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Oylik byudjet + edit + settings
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
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isVeryCompact ? 2 : 6),
                  Text(
                    '${_formatCurrency(budget.totalBudget)} so\'m',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: budgetFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _buildEditButton(Icons.edit, isVeryCompact),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
              icon: Icon(
                Icons.settings,
                color: Colors.white,
                size: isVeryCompact ? 20 : 24,
              ),
              padding: EdgeInsets.all(isVeryCompact ? 4 : 8),
            ),
          ],
        ),

        SizedBox(height: verticalSpacing),

        // Qoldiq
        Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qoldiq',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: labelFontSize,
                ),
              ),
              Flexible(
                child: Text(
                  '${_formatCurrency(budget.remainingBudget)} so\'m',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: remainingFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // Izoh - faqat katta ekranlarda to'liq ko'rinadi
        if (!isVeryCompact) ...[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Izoh',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: labelFontSize * 0.875,
                ),
              ),
              SizedBox(height: verticalSpacing * 0.5),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: cardPadding,
                  vertical: cardPadding * 0.3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(borderRadius * 0.75),
                ),
                child: TextField(
                  controller: descriptionController,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: labelFontSize,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Nimaga sarflandi?',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: onDescriptionChanged,
                ),
              ),
              SizedBox(height: verticalSpacing),
            ],
          ),
        ],

        // Summa kartasi
        _buildValueCard(
          'Summa',
          displayValueFontSize,
          labelFontSize,
          cardPadding,
          borderRadius,
        ),
      ],
    );
  }

  // EDIT REJIM
  Widget _buildEditMode(
    double titleFontSize,
    double budgetFontSize,
    double displayValueFontSize,
    double cardPadding,
    double borderRadius,
    bool isVeryCompact,
  ) {
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
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: isVeryCompact ? 2 : 6),
                  Text(
                    '${_formatCurrency(budget.totalBudget)} so\'m',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: budgetFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            _buildEditButton(Icons.close, isVeryCompact),
          ],
        ),

        const Spacer(),

        // KATTA YANGI BYUDJET KARTASI
        AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(cardPadding * 1.5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius * 1.5),
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
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: isVeryCompact ? 4 : 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$displayValue so\'m',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: displayValueFontSize,
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
  Widget _buildEditButton(IconData icon, bool isVeryCompact) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: IconButton(
        key: ValueKey(icon),
        onPressed: onEditBudget,
        icon: Icon(icon, color: Colors.white),
        iconSize: isVeryCompact ? 20 : 24,
        padding: EdgeInsets.all(isVeryCompact ? 4 : 8),
      ),
    );
  }

  // Summa kartasi (normal rejim)
  Widget _buildValueCard(
    String label,
    double displayValueFontSize,
    double labelFontSize,
    double cardPadding,
    double borderRadius,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
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
              fontSize: labelFontSize * 0.875,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$displayValue so\'m',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: displayValueFontSize * 0.75,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
