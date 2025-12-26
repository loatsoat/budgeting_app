import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final Color? activeColor;
  final Color? inactiveColor;
  final String? label;
  final TextStyle? labelStyle;

  const CustomSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.enabled = true,
    this.activeColor,
    this.inactiveColor,
    this.label,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget switchWidget = Switch(
      value: value,
      onChanged: enabled ? onChanged : null,
      activeThumbColor: activeColor ?? theme.primaryColor,
      inactiveThumbColor: inactiveColor ?? Colors.white,
      inactiveTrackColor: const Color(0xFFCBCED4),
    );

    if (label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label!,
            style: labelStyle ?? theme.textTheme.bodyMedium?.copyWith(
              color: enabled 
                  ? theme.colorScheme.onSurface 
                  : theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 12),
          switchWidget,
        ],
      );
    }

    return switchWidget;
  }
}