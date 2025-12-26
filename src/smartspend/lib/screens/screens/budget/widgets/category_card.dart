import 'package:flutter/material.dart';
import '../../../../models/budget_models.dart';
import '../../../../widgets/components/ui/badge.dart';

class CategoryCard extends StatelessWidget {
  final String categoryKey;
  final CategoryData categoryData;
  final Map<String, SubcategoryBudget> subcategories;
  final bool isExpanded;
  final bool isEditingBudgets;
  final VoidCallback onTap;
  final Function(String, CategoryData) onEditCategory;
  final Widget Function(String, SubcategoryBudget, Color) buildSubcategoryItem;

  const CategoryCard({
    super.key,
    required this.categoryKey,
    required this.categoryData,
    required this.subcategories,
    required this.isExpanded,
    required this.isEditingBudgets,
    required this.onTap,
    required this.onEditCategory,
    required this.buildSubcategoryItem,
  });

  @override
  Widget build(BuildContext context) {
    final totalBudgeted = subcategories.values.fold(
      0.0,
      (sum, budget) => sum + budget.budgeted,
    );
    final totalSpent = subcategories.values.fold(
      0.0,
      (sum, budget) => sum + budget.spent,
    );
    final percentage = totalBudgeted > 0
        ? (totalSpent / totalBudgeted) * 100
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: categoryData.solidColor.withValues(alpha: 0.3),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1F3A).withValues(alpha: 0.8),
            const Color(0xFF2A2F4A).withValues(alpha: 0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: categoryData.glowColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Category header
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Category icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: categoryData.gradientColors,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: categoryData.glowColor.withValues(alpha: 0.4),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        categoryData.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Category info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryData.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '€${totalSpent.toStringAsFixed(0)} / €${totalBudgeted.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: categoryData.solidColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress and actions
                  Column(
                    children: [
                      CustomBadge(
                        text: '${percentage.toStringAsFixed(0)}%',
                        variant: percentage > 90 
                            ? BadgeVariant.destructive 
                            : percentage > 75 
                                ? BadgeVariant.secondary 
                                : BadgeVariant.primary,
                      ),
                      const SizedBox(height: 8),
                      if (isEditingBudgets)
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: categoryData.solidColor,
                            size: 20,
                          ),
                          onPressed: () => onEditCategory(categoryKey, categoryData),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      else
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white70,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Subcategories (when expanded)
          if (isExpanded)
            ...subcategories.entries.map((subEntry) {
              return buildSubcategoryItem(
                subEntry.key,
                subEntry.value,
                categoryData.solidColor,
              );
            }),
        ],
      ),
    );
  }
}
