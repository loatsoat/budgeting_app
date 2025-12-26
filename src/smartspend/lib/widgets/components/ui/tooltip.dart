import 'package:flutter/material.dart';

class CustomTooltip extends StatelessWidget {
  final Widget child;
  final String message;
  final EdgeInsetsGeometry? padding;
  final double? verticalOffset;
  final bool preferBelow;
  final Duration? waitDuration;
  final Duration? showDuration;
  final TextStyle? textStyle;
  final Decoration? decoration;

  const CustomTooltip({
    super.key,
    required this.child,
    required this.message,
    this.padding,
    this.verticalOffset,
    this.preferBelow = true,
    this.waitDuration,
    this.showDuration,
    this.textStyle,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Tooltip(
      message: message,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      verticalOffset: verticalOffset ?? 20,
      preferBelow: preferBelow,
      waitDuration: waitDuration ?? const Duration(milliseconds: 500),
      showDuration: showDuration ?? const Duration(seconds: 2),
      textStyle: textStyle ?? theme.textTheme.bodySmall?.copyWith(
        color: Colors.white,
      ),
      decoration: decoration ?? BoxDecoration(
        color: theme.primaryColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: child,
    );
  }
}

class RichTooltip extends StatelessWidget {
  final Widget child;
  final Widget content;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const RichTooltip({
    super.key,
    required this.child,
    required this.content,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showTooltipDialog(context);
      },
      child: child,
    );
  }

  void _showTooltipDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            top: 100, // Adjust position as needed
            left: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: padding ?? const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor ?? theme.cardColor,
                  borderRadius: borderRadius ?? BorderRadius.circular(8),
                  boxShadow: boxShadow ?? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: content,
              ),
            ),
          ),
        ],
      ),
    );
  }
}