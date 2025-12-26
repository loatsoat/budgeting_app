import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool enabled;
  final Color? activeColor;
  final Color? checkColor;
  final String? label;
  final TextStyle? labelStyle;

  const CustomCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.activeColor,
    this.checkColor,
    this.label,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget checkbox = SizedBox(
      width: 16,
      height: 16,
      child: Checkbox(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: activeColor ?? theme.primaryColor,
        checkColor: checkColor ?? Colors.white,
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );

    if (label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          checkbox,
          const SizedBox(width: 8),
          GestureDetector(
            onTap: enabled ? () => onChanged?.call(!value) : null,
            child: Text(
              label!,
              style: labelStyle ?? theme.textTheme.bodyMedium?.copyWith(
                color: enabled 
                    ? theme.colorScheme.onSurface 
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      );
    }

    return checkbox;
  }
}