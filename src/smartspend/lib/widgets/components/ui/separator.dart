import 'package:flutter/material.dart';

class CustomSeparator extends StatelessWidget {
  final Axis direction;
  final double? thickness;
  final Color? color;
  final double? indent;
  final double? endIndent;

  const CustomSeparator({
    super.key,
    this.direction = Axis.horizontal,
    this.thickness,
    this.color,
    this.indent,
    this.endIndent,
  });

  const CustomSeparator.vertical({
    super.key,
    this.thickness,
    this.color,
    this.indent,
    this.endIndent,
  }) : direction = Axis.vertical;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (direction == Axis.horizontal) {
      return Divider(
        thickness: thickness ?? 1,
        color: color ?? theme.dividerColor,
        indent: indent,
        endIndent: endIndent,
      );
    } else {
      return VerticalDivider(
        thickness: thickness ?? 1,
        color: color ?? theme.dividerColor,
        indent: indent,
        endIndent: endIndent,
      );
    }
  }
}