import 'package:flutter/material.dart';

enum BadgeVariant {
  primary,
  secondary,
  destructive,
  outline,
}

class CustomBadge extends StatelessWidget {
  final String text;
  final BadgeVariant variant;
  final Widget? icon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const CustomBadge({
    super.key,
    required this.text,
    this.variant = BadgeVariant.primary,
    this.icon,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    Color? borderColor;
    
    switch (variant) {
      case BadgeVariant.primary:
        backgroundColor = theme.primaryColor;
        textColor = Colors.white;
        borderColor = null;
        break;
      case BadgeVariant.secondary:
        backgroundColor = theme.colorScheme.secondary;
        textColor = theme.colorScheme.onSecondary;
        borderColor = null;
        break;
      case BadgeVariant.destructive:
        backgroundColor = Colors.red;
        textColor = Colors.white;
        borderColor = null;
        break;
      case BadgeVariant.outline:
        backgroundColor = Colors.transparent;
        textColor = theme.colorScheme.onSurface;
        borderColor = theme.dividerColor;
        break;
    }

    Widget badge = Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: borderColor != null ? Border.all(color: borderColor) : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(
                color: textColor,
                size: 12,
              ),
              child: icon!,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: badge,
      );
    }

    return badge;
  }
}