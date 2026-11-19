import 'package:flutter/material.dart';
import '../../../../services/simple_auth_manager.dart';
import '../../../../widgets/currency_converter_dialog.dart';
import 'profile_menu.dart';

class BudgetHeader extends StatelessWidget {
  final String activeTab;
  final bool isEditingBudgets;
  final VoidCallback onEditToggle;
  final double? budgetAmount;
  final double? totalIncome;
  final VoidCallback? onReturnFromSettings;

  const BudgetHeader({
    super.key,
    required this.activeTab,
    required this.isEditingBudgets,
    required this.onEditToggle,
    this.budgetAmount,
    this.totalIncome,
    this.onReturnFromSettings,
  });

  String _getInitial(BuildContext context) {
    final username = SimpleAuthManager.instance.currentUser?.username ?? 'U';
    return username[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    // Get current month for subtitle
    final now = DateTime.now();
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final currentMonth = monthNames[now.month - 1];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0E1A), // Solid dark background
        border: Border(
          bottom: BorderSide(
            color: Color(0x1AFFFFFF), // Subtle divider
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Left: Profile Avatar (minimal, professional)
          GestureDetector(
            onTap: () => showProfileMenu(context, onReturnFromSettings: onReturnFromSettings),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2A3B5C), // Solid subtle background
                border: Border.all(
                  color: const Color(0xFF5B8DEF).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  _getInitial(context),
                  style: const TextStyle(
                    color: Color(0xFF5B8DEF),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Center-Left: Title and Subtitle (clear hierarchy)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal Wallet',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentMonth,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),

          // Right: Currency Converter (minimal, functional)
          GestureDetector(
            onTap: () {
              final amount = budgetAmount ?? 0;
              showDialog(
                context: context,
                builder: (context) => CurrencyConverterDialog(
                  amount: amount,
                  title: 'Your Budget',
                ),
              );
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.currency_exchange,
                color: Color(0xFF00A8E8),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
