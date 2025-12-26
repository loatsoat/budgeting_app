import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;

  const CustomCard({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin,
      child: Card(
        elevation: elevation ?? 0,
        color: backgroundColor ?? theme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          side: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }
}

class CardHeader extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  const CardHeader({
    super.key,
    this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) title!,
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  subtitle!,
                ],
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 16),
            action!,
          ],
        ],
      ),
    );
  }
}

class CardTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const CardTitle({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Text(
      text,
      style: style ?? theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class CardDescription extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const CardDescription({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Text(
      text,
      style: style ?? theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }
}

class CardContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const CardContent({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );
  }
}

class CardFooter extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const CardFooter({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.only(top: 16),
      child: child,
    );
  }
}