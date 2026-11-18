import 'package:flutter/material.dart';
import '../models/budget_models.dart';

// Bottom sheets and dialogs used by AddTransactionDialog. Each reports the
// user's choice through a callback and leaves applying it to the caller.

void showGoalPicker(
  BuildContext context, {
  required List<SavingsGoal>? savingsGoals,
  required String? selectedGoalId,
  required ValueChanged<String> onSelected,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A2B3F), Color(0xFF0F1A2E)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Select Savings Goal',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ...?savingsGoals?.map(
                  (goal) => ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: goal.color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          goal.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    title: Text(
                      goal.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '€${goal.currentAmount.toStringAsFixed(0)} / €${goal.targetAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    trailing: selectedGoalId == goal.id
                        ? Icon(Icons.check_circle, color: goal.color)
                        : null,
                    onTap: () {
                      onSelected(goal.id);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

void showCategoryPicker(
  BuildContext context, {
  required Map<String, CategoryData> categories,
  Map<String, Map<String, SubcategoryBudget>>? categoryBudgets,
  List<SavingsGoal>? savingsGoals,
  required void Function(
    String categoryKey,
    String? subcategory,
    String? goalId,
  )
  onSelected,
}) {
  String? expandedCategoryKey;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A2B3F),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Select Category',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final entry = categories.entries.elementAt(index);
                      final key = entry.key;
                      final category = entry.value;

                      // For savings category, use savings goals as subcategories
                      final isSavingsCategory = key == 'savings';
                      final subcategories = isSavingsCategory
                          ? null
                          : categoryBudgets?[key];

                      final hasSubcategories = isSavingsCategory
                          ? (savingsGoals?.isNotEmpty ?? false)
                          : (subcategories?.isNotEmpty ?? false);

                      final isExpanded = expandedCategoryKey == key;

                      return Column(
                        children: [
                          ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: category.solidColor.withValues(
                                  alpha: 0.2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  category.icon,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            title: Text(
                              category.name,
                              style: const TextStyle(color: Colors.white),
                            ),
                            trailing: hasSubcategories
                                ? Icon(
                                    isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Colors.white70,
                                  )
                                : null,
                            onTap: () {
                              if (hasSubcategories) {
                                // Toggle expansion
                                setModalState(() {
                                  expandedCategoryKey = isExpanded ? null : key;
                                });
                              } else {
                                // Select category directly
                                onSelected(key, null, null);
                                Navigator.pop(context);
                              }
                            },
                          ),
                          // Show savings goals as subcategories for savings category
                          if (isExpanded &&
                              isSavingsCategory &&
                              savingsGoals != null)
                            ...savingsGoals.map(
                              (goal) => ListTile(
                                contentPadding: const EdgeInsets.only(
                                  left: 72,
                                  right: 16,
                                ),
                                leading: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: goal.color.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      goal.emoji,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  goal.name,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                subtitle: Text(
                                  '€${goal.currentAmount.toStringAsFixed(0)} / €${goal.targetAmount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: goal.color.withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                onTap: () {
                                  onSelected(key, goal.name, goal.id);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          // Show regular subcategories for other categories
                          if (isExpanded &&
                              !isSavingsCategory &&
                              hasSubcategories)
                            ...subcategories!.keys.map(
                              (subName) => ListTile(
                                contentPadding: const EdgeInsets.only(
                                  left: 72,
                                  right: 16,
                                ),
                                title: Text(
                                  subName,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                onTap: () {
                                  onSelected(key, subName, null);
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

void showSubcategoryPicker(
  BuildContext context,
  Map<String, SubcategoryBudget>? subcategories,
  ValueChanged<String> onSelected,
) {
  if (subcategories == null || subcategories.isEmpty) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A2B3F),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select Subcategory',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: subcategories.length,
                  itemBuilder: (context, index) {
                    final subName = subcategories.keys.elementAt(index);
                    return ListTile(
                      title: Text(
                        subName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        onSelected(subName);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    ),
  );
}
