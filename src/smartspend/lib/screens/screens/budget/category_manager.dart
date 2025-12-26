import 'package:flutter/material.dart';
import '../../../models/budget_models.dart';

/// Simple, reusable dialogs for category & subcategory management.
/// The maps are mutated directly; caller should call setState after changes.
Future<void> showManageCategoriesDialog(
  BuildContext context,
  Map<String, CategoryData> categories,
  Map<String, Map<String, SubcategoryBudget>> categoryBudgets,
  void Function(String key, CategoryData data) onEditCategory,
  VoidCallback onChanged,
) {
  return showDialog(
    context: context,
    builder: (context) {
      final keys = categories.keys.toList();
      return AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text('Manage Categories', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: keys.map((k) {
              final cd = categories[k]!;
              final count = categoryBudgets[k]?.length ?? 0;
              final isIncome = k == 'income';
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cd.solidColor.withValues(alpha:0.15),
                  ),
                  child: Center(child: Text(cd.icon)),
                ),
                title: Text(cd.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text('$count subcategories', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                onTap: () {
                  Navigator.pop(context);
                  onEditCategory(k, cd);
                },
                trailing: isIncome
                    ? Icon(Icons.lock, color: Colors.white54) // income cannot be deleted
                    : IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: const Color(0xFF1A1F3A),
                              title: Text('Delete ${cd.name}?', style: const TextStyle(color: Colors.white)),
                              content: Text(
                                'This will remove the category and all its subcategories.',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            categories.remove(k);
                            categoryBudgets.remove(k);
                            onChanged();
                            if (context.mounted) Navigator.pop(context); // close manage dialog
                            // reopen to show updated list
                            if (context.mounted) await showManageCategoriesDialog(context, categories, categoryBudgets, onEditCategory, onChanged);
                          }
                        },
                      ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F5FF)),
            onPressed: () {
              Navigator.pop(context);
              showAddCategoryDialog(
                context,
                categories,
                categoryBudgets,
                onSaved: onChanged,
              );
            },
            child: const Text('Add Category'),
          ),
        ],
      );
    },
  );
}

Future<void> showEditCategoryDialog(
  BuildContext context,
  Map<String, CategoryData> categories,
  String categoryKey,
  CategoryData categoryData,
  Map<String, Map<String, SubcategoryBudget>> categoryBudgets,
  VoidCallback onChanged,
) {
  final subcats = categoryBudgets[categoryKey] ?? {};
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A1F3A),
      title: Text('Edit ${categoryData.name}', style: const TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subcats.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No subcategories yet.', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
              )
            else
              ...subcats.entries.map((e) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.key, style: const TextStyle(color: Colors.white)),
                  subtitle: Text('€${e.value.budgeted.toStringAsFixed(0)}', style: TextStyle(color: categoryData.solidColor)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                        onPressed: () {
                          Navigator.pop(context);
                          showAddOrEditSubcategoryDialog(
                            context,
                            categoryKey,
                            categoryData,
                            categoryBudgets,
                            initialName: e.key,
                            initialBudget: e.value.budgeted,
                            onSaved: onChanged,
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                        onPressed: () {
                          categoryBudgets[categoryKey]?.remove(e.key);
                          onChanged();
                          Navigator.pop(context);
                          // reopen to reflect changes
                          showEditCategoryDialog(context, categories, categoryKey, categoryData, categoryBudgets, onChanged);
                        },
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: categoryData.solidColor),
              onPressed: () {
                Navigator.pop(context);
                showAddOrEditSubcategoryDialog(
                  context,
                  categoryKey,
                  categoryData,
                  categoryBudgets,
                  onSaved: onChanged,
                );
              },
              child: const Text('Add Subcategory'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(color: Colors.white70))),
      ],
    ),
  );
}

Future<void> showAddCategoryDialog(
  BuildContext context,
  Map<String, CategoryData> categories,
  Map<String, Map<String, SubcategoryBudget>> categoryBudgets, {
  required VoidCallback onSaved,
}) {
  final nameCtrl = TextEditingController();
  final emojiCtrl = TextEditingController();

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A1F3A),
      title: const Text('Add New Category', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Category name',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF2A2F4A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: emojiCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 20),
            maxLength: 2,
            decoration: InputDecoration(
              hintText: 'Emoji (e.g. 🏠)',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF2A2F4A),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F5FF)),
          onPressed: () {
            final name = nameCtrl.text.trim();
            final emoji = emojiCtrl.text.trim().isNotEmpty ? emojiCtrl.text.trim() : '📁';
            if (name.isEmpty) return;
            final key = name.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
            // ensure unique key
            var newKey = key;
            var i = 1;
            while (categories.containsKey(newKey)) {
              newKey = '${key}_$i';
              i++;
            }
            categories[newKey] = CategoryData(
              name: name,
              gradientColors: [const Color(0xFF00F5FF), const Color(0xFF00D4FF)],
              solidColor: const Color(0xFF00F5FF),
              glowColor: const Color(0xFF00F5FF).withValues(alpha: 0.6),
              icon: emoji,
              subcategories: [],
            );
            categoryBudgets.putIfAbsent(newKey, () => {});
            onSaved();
            Navigator.pop(context);
          },
          child: const Text('Create'),
        ),
      ],
    ),
  );
}

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
  final budgetCtrl = TextEditingController(text: initialBudget != null ? initialBudget.toStringAsFixed(0) : '');
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF1A1F3A),
      title: Text(initialName == null ? 'Add to ${categoryData.name}' : 'Edit $initialName', style: const TextStyle(color: Colors.white)),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: categoryData.solidColor),
          onPressed: () {
            final name = nameCtrl.text.trim();
            final budget = double.tryParse(budgetCtrl.text) ?? 0.0;
            if (name.isEmpty) return;
            categoryBudgets.putIfAbsent(categoryKey, () => {});
            final map = categoryBudgets[categoryKey]!;
            if (initialName != null && initialName != name) {
              // rename key
              final old = map.remove(initialName);
              map[name] = SubcategoryBudget(budgeted: budget, spent: old?.spent ?? 0);
            } else {
              map[name] = SubcategoryBudget(budgeted: budget, spent: map[initialName]?.spent ?? 0);
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

/// Dialog to edit the overall budget amount
Future<void> showEditBudgetDialog(
  BuildContext context,
  double currentBudget,
  void Function(double newBudget) onSaved,
) {
  final ctrl = TextEditingController(text: currentBudget.toStringAsFixed(0));
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color.fromARGB(255, 13, 132, 132),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text('Edit Tota Budget', style: TextStyle(color: Color.fromARGB(255, 10, 9, 9))),
      content: TextField(
        controller: ctrl,
        style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Budget (€)',
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF1A1F33),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: const Color(0xFF00F5FF).withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: const Color(0xFF00F5FF).withOpacity(0.12)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00F5FF)),
          onPressed: () {
            final newBudget = double.tryParse(ctrl.text) ?? currentBudget;
            onSaved(newBudget);
            Navigator.pop(context);
          },
          child: const Text('Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}