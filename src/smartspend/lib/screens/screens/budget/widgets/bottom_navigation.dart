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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    // Dynamic navigation bar height
    final navHeight = (screenHeight * 0.09).clamp(56.0, 80.0);
    final fabSize = (screenWidth * 0.14).clamp(56.0, 68.0);

    return SizedBox(
      height: navHeight + fabSize * 0.5 + bottomInset,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Navigation bar background
          Container(
            height: navHeight + bottomInset,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1A1F33),
                  Color(0xFF0A0E1A),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Left item (OVERVIEW)
                Expanded(
                  child: Center(
                    child: _buildNavItem(
                      context,
                      'overview',
                      Icons.visibility,
                      'OVERVIEW',
                      const LinearGradient(
                        colors: [Color(0xFF00F5FF), Color(0xFF00B8FF)],
                      ),
                    ),
                  ),
                ),
                
                // Space for the FAB
                SizedBox(width: fabSize + 20),
                
                // Right item (BUDGET)
                Expanded(
                  child: Center(
                    child: _buildNavItem(
                      context,
                      'budget',
                      Icons.account_balance_wallet,
                      'BUDGET',
                      const LinearGradient(
                        colors: [Color(0xFFFF6B9D), Color(0xFFFF3D8F)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Center FAB
          Positioned(
            bottom: navHeight * 0.5 + bottomInset,
            child: GestureDetector(
              onTap: onAddTransaction,
              child: Container(
                width: fabSize,
                height: fabSize,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B9D), Color(0xFFFF3D8F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B9D).withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(Icons.add, color: Colors.white, size: fabSize * 0.45),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String tabKey, 
    IconData icon, 
    String label, 
    Gradient gradient
  ) {
    final isActive = activeTab == tabKey;

    return GestureDetector(
      onTap: () => onTabChanged(tabKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isActive ? gradient : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
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
    );
  }
}