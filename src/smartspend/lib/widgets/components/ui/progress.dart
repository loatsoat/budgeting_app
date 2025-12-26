import 'package:flutter/material.dart';

class CustomProgress extends StatelessWidget {
  final double value;
  final double? height;
  final Color? backgroundColor;
  final Color? valueColor;
  final BorderRadius? borderRadius;
  final String? label;
  final bool showPercentage;

  const CustomProgress({
    super.key,
    required this.value,
    this.height,
    this.backgroundColor,
    this.valueColor,
    this.borderRadius,
    this.label,
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedValue = value.clamp(0.0, 1.0);
    
    Widget progressBar = Container(
      height: height ?? 8,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.primaryColor.withValues(alpha: 0.2),
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: clampedValue,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            valueColor ?? theme.primaryColor,
          ),
        ),
      ),
    );

    if (label != null || showPercentage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null || showPercentage)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: theme.textTheme.bodySmall,
                  ),
                if (showPercentage)
                  Text(
                    '${(clampedValue * 100).round()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 4),
          progressBar,
        ],
      );
    }

    return progressBar;
  }
}

class CircularProgress extends StatelessWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? valueColor;
  final Widget? child;

  const CircularProgress({
    super.key,
    required this.value,
    this.size = 40,
    this.strokeWidth = 4,
    this.backgroundColor,
    this.valueColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value.clamp(0.0, 1.0),
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor ?? theme.primaryColor.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              valueColor ?? theme.primaryColor,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}