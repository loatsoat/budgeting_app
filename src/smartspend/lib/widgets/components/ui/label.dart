import 'package:flutter/material.dart';

class CustomLabel extends StatelessWidget {
  final String text;
  final Widget? child;
  final TextStyle? style;
  final bool required;
  final Widget? icon;

  const CustomLabel({
    super.key,
    required this.text,
    this.child,
    this.style,
    this.required = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(
              size: 16,
              color: theme.colorScheme.onSurface,
            ),
            child: icon!,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: style ?? theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        if (required)
          Text(
            ' *',
            style: TextStyle(
              color: Colors.red,
              fontSize: (style?.fontSize ?? theme.textTheme.labelMedium?.fontSize ?? 14),
            ),
          ),
      ],
    );

    if (child != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label,
          const SizedBox(height: 6),
          child!,
        ],
      );
    }

    return label;
  }
}