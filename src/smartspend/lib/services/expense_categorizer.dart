import 'dart:math';

class ExpenseCategorizer {
  static final ExpenseCategorizer _instance = ExpenseCategorizer._internal();

  factory ExpenseCategorizer() {
    return _instance;
  }

  ExpenseCategorizer._internal();

  // Category keywords mapping
  final Map<String, List<String>> categoryKeywords = {
    'Food & Dining': [
      'restaurant',
      'food',
      'cafe',
      'coffee',
      'pizza',
      'burger',
      'sushi',
      'lunch',
      'dinner',
      'breakfast',
      'grocery',
      'supermarket',
      'bakery',
      'deli',
      'fast food',
      'uber eats',
      'doordash',
      'grubhub',
      'starbucks',
      'mcdonalds',
      'trader joe',
      'whole foods',
    ],
    'Transportation': [
      'uber',
      'lyft',
      'taxi',
      'gas',
      'fuel',
      'parking',
      'transit',
      'metro',
      'train',
      'bus',
      'airline',
      'flight',
      'car rental',
      'tesla',
      'electric charging',
      'exxon',
      'shell',
      'chevron',
    ],
    'Shopping': [
      'amazon',
      'mall',
      'store',
      'retail',
      'target',
      'walmart',
      'costco',
      'shopping',
      'clothes',
      'apparel',
      'department',
      'nike',
      'adidas',
      'best buy',
      'store',
    ],
    'Entertainment': [
      'movie',
      'theater',
      'netflix',
      'spotify',
      'hulu',
      'disney',
      'gaming',
      'game',
      'steam',
      'playstation',
      'xbox',
      'concert',
      'ticket',
      'cinema',
      'entertainment',
      'twitch',
    ],
    'Utilities': [
      'electric',
      'water',
      'gas',
      'internet',
      'phone',
      'verizon',
      'at&t',
      't-mobile',
      'comcast',
      'utility',
      'power',
      'cable',
    ],
    'Healthcare': [
      'pharmacy',
      'doctor',
      'hospital',
      'medical',
      'clinic',
      'cvs',
      'walgreens',
      'health',
      'dentist',
      'dental',
      'medicine',
      'prescription',
      'healthcare',
    ],
    'Fitness': [
      'gym',
      'yoga',
      'fitness',
      'peloton',
      'planet fitness',
      'sports',
      'athletic',
      'trainer',
      'running',
    ],
    'Personal Care': [
      'salon',
      'haircut',
      'barber',
      'spa',
      'beauty',
      'massage',
      'grooming',
      'nail',
      'cosmetic',
    ],
    'Travel': [
      'hotel',
      'airbnb',
      'booking',
      'resort',
      'vacation',
      'trip',
      'travel',
      'motel',
      'lodging',
    ],
    'Financial Services': [
      'bank',
      'atm',
      'credit',
      'loan',
      'mortgage',
      'insurance',
      'broker',
      'investment',
      'paypal',
      'square cash',
      'venmo',
    ],
  };

  // Get similarity score between two strings (0 to 1)
  double _stringSimilarity(String a, String b) {
    final aLower = a.toLowerCase();
    final bLower = b.toLowerCase();

    if (aLower == bLower) return 1.0;
    if (aLower.contains(bLower) || bLower.contains(aLower)) return 0.8;

    // Levenshtein distance based similarity
    final distance = _levenshteinDistance(aLower, bLower);
    final maxLength = max(aLower.length, bLower.length);
    return 1.0 - (distance / maxLength);
  }

  // Levenshtein distance algorithm
  int _levenshteinDistance(String a, String b) {
    final aLength = a.length;
    final bLength = b.length;
    final distances = List<List<int>>.generate(
      aLength + 1,
      (i) => List<int>.filled(bLength + 1, 0),
    );

    for (var i = 0; i <= aLength; i++) {
      distances[i][0] = i;
    }
    for (var j = 0; j <= bLength; j++) {
      distances[0][j] = j;
    }

    for (var i = 1; i <= aLength; i++) {
      for (var j = 1; j <= bLength; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        distances[i][j] = min(
          min(
            distances[i - 1][j] + 1,
            distances[i][j - 1] + 1,
          ),
          distances[i - 1][j - 1] + cost,
        );
      }
    }

    return distances[aLength][bLength];
  }

  /// Categorize expense based on description and merchant
  CategoryPrediction categorizeExpense({
    required String description,
    required String? merchantName,
  }) {
    final text = '${description.toLowerCase()} ${merchantName?.toLowerCase() ?? ''}';

    // Score each category
    final categoryScores = <String, double>{};

    categoryKeywords.forEach((category, keywords) {
      int matches = 0;

      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          matches++;
        }
      }

      // Calculate confidence based on matches
      if (matches > 0) {
        // Confidence increases with more matches
        // 1 match = 0.5, 2 matches = 0.8, 3+ matches = 1.0
        double confidence = 0.5;
        if (matches >= 2) confidence = 0.8;
        if (matches >= 3) confidence = 1.0;
        
        categoryScores[category] = confidence * 100; // Store as 0-100 for sorting
      }
    });

    // Find best match
    if (categoryScores.isEmpty) {
      return CategoryPrediction(
        category: 'Other',
        confidence: 0.0,
        alternativeCategories: [],
      );
    }

    final bestEntry =
        categoryScores.entries.reduce((a, b) => a.value > b.value ? a : b);
    final bestCategory = bestEntry.key;
    final bestScore = bestEntry.value / 100; // Convert back to 0-1

    // Get alternatives (top 3, excluding best)
    final alternatives = _getTopAlternatives(categoryScores, 4)
        .where((alt) => alt.category != bestCategory)
        .take(3)
        .toList();

    return CategoryPrediction(
      category: bestCategory,
      confidence: bestScore,
      alternativeCategories: alternatives,
    );
  }

  /// Get top N alternative categories
  List<CategoryAlternative> _getTopAlternatives(
    Map<String, double> categoryScores,
    int limit,
  ) {
    final sortedCategories = categoryScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedCategories
        .take(limit)
        .map((e) {
          final confidence = e.value / 100; // Already 0-100, convert to 0-1
          return CategoryAlternative(
            category: e.key,
            confidence: confidence,
          );
        })
        .toList();
  }

  /// Get all available categories
  List<String> getAvailableCategories() {
    return categoryKeywords.keys.toList();
  }

  /// Manual category suggestion based on keywords
  String suggestCategoryFromKeywords(String text) {
    final categorization = categorizeExpense(
      description: text,
      merchantName: null,
    );
    return categorization.category;
  }
}

class CategoryPrediction {
  final String category;
  final double confidence;
  final List<CategoryAlternative> alternativeCategories;

  CategoryPrediction({
    required this.category,
    required this.confidence,
    required this.alternativeCategories,
  });

  bool get isHighConfidence => confidence > 0.7;
  bool get isMediumConfidence => confidence > 0.4 && confidence <= 0.7;
  bool get isLowConfidence => confidence <= 0.4;

  @override
  String toString() {
    return 'CategoryPrediction(category: $category, confidence: $confidence)';
  }
}

class CategoryAlternative {
  final String category;
  final double confidence;

  CategoryAlternative({
    required this.category,
    required this.confidence,
  });
}
