import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? contentPadding;
  final bool barrierDismissible;

  const CustomDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.contentPadding,
    this.barrierDismissible = true,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    Widget? title,
    Widget? content,
    List<Widget>? actions,
    EdgeInsetsGeometry? contentPadding,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog(
        title: title,
        content: content,
        actions: actions,
        contentPadding: contentPadding,
        barrierDismissible: barrierDismissible,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title,
      content: content,
      actions: actions,
      contentPadding: contentPadding ?? const EdgeInsets.fromLTRB(24, 20, 24, 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class DialogHeader extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;

  const DialogHeader({
    super.key,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) title!,
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          subtitle!,
        ],
      ],
    );
  }
}

class DialogTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const DialogTitle({
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

class DialogDescription extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const DialogDescription({
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

class DialogFooter extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;

  const DialogFooter({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.end,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: children,
    );
  }
}