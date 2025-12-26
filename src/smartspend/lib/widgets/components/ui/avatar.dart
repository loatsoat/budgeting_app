import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? fallbackText;
  final Widget? fallbackIcon;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final VoidCallback? onTap;

  const CustomAvatar({
    super.key,
    this.imageUrl,
    this.fallbackText,
    this.fallbackIcon,
    this.size = 40,
    this.backgroundColor,
    this.foregroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget avatar = CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor ?? theme.colorScheme.secondary,
      foregroundColor: foregroundColor ?? theme.colorScheme.onSecondary,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? (fallbackIcon ?? 
              (fallbackText != null 
                  ? Text(
                      fallbackText!,
                      style: TextStyle(
                        fontSize: size * 0.4,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: size * 0.6,
                    )))
          : null,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }
}

class AvatarGroup extends StatelessWidget {
  final List<CustomAvatar> avatars;
  final int maxVisible;
  final double spacing;

  const AvatarGroup({
    super.key,
    required this.avatars,
    this.maxVisible = 3,
    this.spacing = -8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visibleAvatars = avatars.take(maxVisible).toList();
    final remainingCount = avatars.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...visibleAvatars.asMap().entries.map((entry) {
          final index = entry.key;
          final avatar = entry.value;
          
          return Container(
            margin: EdgeInsets.only(left: index > 0 ? spacing : 0),
            child: avatar,
          );
        }),
        if (remainingCount > 0)
          Container(
            margin: EdgeInsets.only(left: spacing),
            child: CustomAvatar(
              size: visibleAvatars.isNotEmpty ? visibleAvatars.first.size : 40,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              fallbackText: '+$remainingCount',
            ),
          ),
      ],
    );
  }
}