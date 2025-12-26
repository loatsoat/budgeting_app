import 'package:flutter/material.dart';

enum AlertVariant {
  info,
  destructive,
}

class CustomAlert extends StatelessWidget {
  final Widget? title;
  final Widget? description;
  final Widget? icon;
  final AlertVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const CustomAlert({
    super.key,
    this.title,
    this.description,
    this.icon,
    this.variant = AlertVariant.info,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color textColor;
    Color borderColor;
    
    switch (variant) {
      case AlertVariant.info:
        backgroundColor = theme.cardColor;
        textColor = theme.colorScheme.onSurface;
        borderColor = theme.dividerColor;
        break;
      case AlertVariant.destructive:
        backgroundColor = theme.cardColor;
        textColor = Colors.red;
        borderColor = Colors.red.withValues();
        break;
    }

    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            IconTheme(
              data: IconThemeData(
                color: textColor,
                size: 16,
              ),
              child: icon!,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  DefaultTextStyle(
                    style: theme.textTheme.titleSmall!.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                    child: title!,
                  ),
                  if (description != null) const SizedBox(height: 4),
                ],
                if (description != null)
                  DefaultTextStyle(
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: variant == AlertVariant.destructive 
                          ? textColor.withValues(alpha: 0.9)
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    child: description!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AlertTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const AlertTitle({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style);
  }
}

class AlertDescription extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const AlertDescription({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style);
  }
}