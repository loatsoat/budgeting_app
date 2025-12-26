import 'package:flutter/material.dart';

enum ButtonVariant {
  primary,
  destructive,
  outline,
  secondary,
  ghost,
  link,
}

enum ButtonSize {
  small,
  medium,
  large,
  icon,
}

class CustomButton extends StatelessWidget {
  final String? text;
  final Widget? child;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool disabled;
  final Widget? icon;

  const CustomButton({
    super.key,
    this.text,
    this.child,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.disabled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Get button styling based on variant
    ButtonStyle buttonStyle = _getButtonStyle(theme);
    
    // Get button size
    Size buttonSize = _getButtonSize();
    
    Widget buttonChild = child ?? 
        (icon != null 
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon!,
                  if (text != null) ...[
                    const SizedBox(width: 8),
                    Text(text!),
                  ],
                ],
              )
            : Text(text ?? ''));

    return SizedBox(
      height: buttonSize.height,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: buttonStyle,
        child: buttonChild,
      ),
    );
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        );
      case ButtonVariant.destructive:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        );
      case ButtonVariant.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 0,
          side: BorderSide(color: theme.dividerColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        );
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        );
      case ButtonVariant.ghost:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.onSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        );
      case ButtonVariant.link:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: theme.primaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        );
    }
  }

  Size _getButtonSize() {
    switch (size) {
      case ButtonSize.small:
        return const Size(double.infinity, 32);
      case ButtonSize.medium:
        return const Size(double.infinity, 36);
      case ButtonSize.large:
        return const Size(double.infinity, 40);
      case ButtonSize.icon:
        return const Size(36, 36);
    }
  }
}