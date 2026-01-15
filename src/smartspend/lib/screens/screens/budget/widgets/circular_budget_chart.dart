import 'package:flutter/material.dart';

class CircularBudgetChart extends StatelessWidget {
  final double totalBudget;
  final double totalSpent;
  final double budgetLeft;
  final double budgetPercentage;
  final VoidCallback? onBudgetTap; // ADD THIS

  const CircularBudgetChart({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
    required this.budgetLeft,
    required this.budgetPercentage,
    this.onBudgetTap, // ADD THIS
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFF00F5FF).withValues(alpha:0.3),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1F3A),
            Color(0xFF2A2F4A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F5FF).withValues(alpha:0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Budget Circle
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 2,
                    ),
                  ),
                ),
                // Progress circle
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: (budgetPercentage / 100).clamp(0.0, 1.0),
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      budgetPercentage > 100
                          ? Colors.red
                          : budgetPercentage > 80
                          ? const Color(0xFFFFAA00)
                          : const Color(0xFF00FF88),
                    ),
                  ),
                ),
                // Center content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '€${budgetLeft.abs().toStringAsFixed(0)}',
                      style: TextStyle(
                        color: budgetLeft < 0 ? Colors.red : const Color(0xFF00FF88),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      budgetLeft < 0 ? 'budget exceeded' : 'left to spend',
                      style: TextStyle(
                        color: budgetLeft < 0 ? Colors.red.withValues(alpha: 0.7) : Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${budgetPercentage.toStringAsFixed(1)}% used',
                      style: TextStyle(
                        color: budgetPercentage > 100
                            ? Colors.red
                            : budgetPercentage > 80
                            ? const Color(0xFFFFAA00)
                            : const Color(0xFF00FF88),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Budget summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Budget',
                '€${totalBudget.toStringAsFixed(0)}',
                const Color(0xFF00F5FF),
                onTap: onBudgetTap, // ADD THIS PARAMETER
              ),
              _buildSummaryItem(
                'Spent',
                '€${totalSpent.toStringAsFixed(0)}',
                const Color(0xFFFF6B9D),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    Color color, {
    VoidCallback? onTap,
  }) {
    final content = Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.edit,
                color: color.withValues(alpha:0.7),
                size: 16,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );

    if (onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: content,
          ),
        ),
      );
    }
    return content;
  }
}
