import 'package:flutter/material.dart';

class BudgetBottomNavigation extends StatelessWidget {
  final String activeTab;
  final Function(String) onTabChanged;
  final VoidCallback? onAddTransaction;

  const BudgetBottomNavigation({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
    this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // Dynamic navigation bar height
    final navHeight = 70.0;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          height: navHeight + bottomInset,
          decoration: const BoxDecoration(
            color: Color(0xFF2A3B5C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // OVERVIEW tab
              Expanded(
                child: Center(
                  child: _buildNavItem(
                    context,
                    'overview',
                    Icons.visibility,
                    'OVERVIEW',
                    const LinearGradient(
                      colors: [Color(0xFF5B8DEF), Color(0xFF4A7BC8)],
                    ),
                  ),
                ),
              ),

              // ADD button spacer
              Expanded(
                child: Container(),
              ),

              // BUDGET tab
              Expanded(
                child: Center(
                  child: _buildNavItem(
                    context,
                    'budget',
                    Icons.account_balance_wallet,
                    'BUDGET',
                    const LinearGradient(
                      colors: [Color(0xFF5B8DEF), Color(0xFF4A7BC8)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // ADD button (floating above navigation)
        Positioned(
          bottom: navHeight / 2 - 32,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: onAddTransaction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0D47A1),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D47A1).withValues(alpha: 0.6),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: const Color(0xFF0D47A1).withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFF0D47A1).withValues(alpha: 0.2),
                    ),
                    child: const Text(
                      'ADD',
                      style: TextStyle(
                        color: Color(0xFF5B8DEF),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            color: Color(0xFF5B8DEF),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String tabKey,
    IconData icon,
    String label,
    Gradient gradient,
  ) {
    final isActive = activeTab == tabKey;

    return GestureDetector(
      onTap: () => onTabChanged(tabKey),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: SizedBox(
              width: 90,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 22),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isActive)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(top: 4),
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF5B8DEF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}
