import 'package:flutter/material.dart';
import '../../../models/budget_models.dart';

Future<void> showAddOrEditSubcategoryDialog(
  BuildContext context,
  String categoryKey,
  CategoryData categoryData,
  Map<String, Map<String, SubcategoryBudget>> categoryBudgets, {
  String? initialName,
  double? initialBudget,
  required VoidCallback onSaved,
}) {
  final nameCtrl = TextEditingController(text: initialName ?? '');
  final budgetCtrl = TextEditingController(
    text: initialBudget != null ? initialBudget.toStringAsFixed(0) : '',
  );
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A1F3A),
      title: Text(
        initialName == null
            ? 'Add to ${categoryData.name}'
            : 'Edit $initialName',
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Subcategory name',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF2A2F4A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: budgetCtrl,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Budget (€)',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF2A2F4A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: categoryData.solidColor,
          ),
          onPressed: () {
            final name = nameCtrl.text.trim();
            final budget = double.tryParse(budgetCtrl.text) ?? 0.0;
            if (name.isEmpty) return;
            categoryBudgets.putIfAbsent(categoryKey, () => {});
            final map = categoryBudgets[categoryKey]!;
            if (initialName != null && initialName != name) {
              // rename key
              final old = map.remove(initialName);
              map[name] = SubcategoryBudget(
                budgeted: budget,
                spent: old?.spent ?? 0,
              );
            } else {
              map[name] = SubcategoryBudget(
                budgeted: budget,
                spent: map[initialName]?.spent ?? 0,
              );
            }
            onSaved();
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
