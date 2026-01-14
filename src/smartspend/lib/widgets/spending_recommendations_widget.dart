import 'package:flutter/material.dart';
import '../services/spending_recommendations_service.dart';

class SpendingRecommendationsWidget extends StatelessWidget {
  final List<SpendingRecommendation> recommendations;
  final VoidCallback? onDismiss;

  const SpendingRecommendationsWidget({
    Key? key,
    required this.recommendations,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF00F5FF),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Smart Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final recommendation = recommendations[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == recommendations.length - 1 ? 0 : 16,
                ),
                child: SizedBox(
                  width: 300,
                  child: _buildRecommendationCard(context, recommendation),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    SpendingRecommendation recommendation,
  ) {
    final colors = _getColorForType(recommendation.type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            colors['bg']!.withValues(alpha: 0.5),
            colors['bg']!.withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(
          color: colors['border']!.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors['icon']!.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconForType(recommendation.type),
                  color: colors['icon'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommendation.message,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (recommendation.relatedAmount != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colors['badge']!.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '€${recommendation.relatedAmount!.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: colors['badge'],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Map<String, Color> _getColorForType(RecommendationType type) {
    switch (type) {
      case RecommendationType.alert:
        return {
          'bg': const Color(0xFFFF4D67),
          'border': const Color(0xFFFF4D67),
          'icon': const Color(0xFFFF4D67),
          'badge': const Color(0xFFFF4D67),
        };
      case RecommendationType.warning:
        return {
          'bg': const Color(0xFFFFA500),
          'border': const Color(0xFFFFA500),
          'icon': const Color(0xFFFFA500),
          'badge': const Color(0xFFFFA500),
        };
      case RecommendationType.positive:
        return {
          'bg': const Color(0xFF4CAF50),
          'border': const Color(0xFF4CAF50),
          'icon': const Color(0xFF4CAF50),
          'badge': const Color(0xFF4CAF50),
        };
      case RecommendationType.insight:
        return {
          'bg': const Color(0xFF00F5FF),
          'border': const Color(0xFF00F5FF),
          'icon': const Color(0xFF00F5FF),
          'badge': const Color(0xFF00F5FF),
        };
    }
  }

  IconData _getIconForType(RecommendationType type) {
    switch (type) {
      case RecommendationType.alert:
        return Icons.warning_rounded;
      case RecommendationType.warning:
        return Icons.error_outline;
      case RecommendationType.positive:
        return Icons.check_circle_outline;
      case RecommendationType.insight:
        return Icons.lightbulb_outline;
    }
  }
}
