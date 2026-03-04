import 'package:flutter/material.dart';
import '../services/expense_categorizer.dart';

class CategorySuggestionWidget extends StatefulWidget {
  final String description;
  final String? merchantName;
  final Function(String) onCategorySelected;
  final String? initialCategory;

  const CategorySuggestionWidget({
    Key? key,
    required this.description,
    this.merchantName,
    required this.onCategorySelected,
    this.initialCategory,
  }) : super(key: key);

  @override
  State<CategorySuggestionWidget> createState() =>
      _CategorySuggestionWidgetState();
}

class _CategorySuggestionWidgetState extends State<CategorySuggestionWidget> {
  final ExpenseCategorizer _categorizer = ExpenseCategorizer();
  late CategoryPrediction _prediction;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _prediction = _categorizer.categorizeExpense(
      description: widget.description,
      merchantName: widget.merchantName,
    );
    _selectedCategory = widget.initialCategory ?? _prediction.category;
  }

  @override
  void didUpdateWidget(CategorySuggestionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.description != widget.description ||
        oldWidget.merchantName != widget.merchantName) {
      _prediction = _categorizer.categorizeExpense(
        description: widget.description,
        merchantName: widget.merchantName,
      );
      _selectedCategory = _prediction.category;
    }
  }

  Color _getConfidenceColor() {
    if (_prediction.isHighConfidence) return Colors.green;
    if (_prediction.isMediumConfidence) return Colors.orange;
    return Colors.red;
  }

  String _getConfidenceLabel() {
    if (_prediction.isHighConfidence) return 'High Confidence';
    if (_prediction.isMediumConfidence) return 'Medium Confidence';
    return 'Low Confidence';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Suggested category header
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Suggested Category',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getConfidenceLabel(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getConfidenceColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Main category button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showCategoryDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                  foregroundColor: Colors.blue.shade900,
                  elevation: 0,
                ),
                child: Text(
                  _selectedCategory,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Confidence score bar
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _prediction.confidence,
                minHeight: 6,
                backgroundColor: Colors.grey.shade300,
                valueColor:
                    AlwaysStoppedAnimation<Color>(_getConfidenceColor()),
              ),
            ),

            // Alternative categories (if available)
            if (_prediction.alternativeCategories.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Alternatives:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: _prediction.alternativeCategories
                    .take(2)
                    .map((alt) => ActionChip(
                          label: Text(
                            alt.category,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            setState(() => _selectedCategory = alt.category);
                            widget.onCategorySelected(alt.category);
                          },
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context) {
    final categories = _categorizer.getAvailableCategories();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == _selectedCategory;

              return ListTile(
                title: Text(category),
                trailing:
                    isSelected ? const Icon(Icons.check_circle) : null,
                onTap: () {
                  setState(() => _selectedCategory = category);
                  widget.onCategorySelected(category);
                  Navigator.pop(context);
                },
                selected: isSelected,
              );
            },
          ),
        ),
      ),
    );
  }
}
