import 'package:flutter/material.dart';

class CustomSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration? duration;

  const CustomSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
    this.duration,
  });

  const CustomSkeleton.rectangular({
    super.key,
    this.width,
    this.height,
    this.baseColor,
    this.highlightColor,
    this.duration,
  }) : borderRadius = null;

  const CustomSkeleton.circular({
    super.key,
    required double size,
    this.baseColor,
    this.highlightColor,
    this.duration,
  }) : width = size,
        height = size,
        borderRadius = const BorderRadius.all(Radius.circular(1000));

  @override
  State<CustomSkeleton> createState() => _CustomSkeletonState();
}

class _CustomSkeletonState extends State<CustomSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = widget.baseColor ?? theme.colorScheme.surface;
    final highlightColor = widget.highlightColor ?? 
        theme.colorScheme.onSurface.withValues(alpha: 0.1);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height ?? 16,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                Color.lerp(baseColor, highlightColor, _animation.value)!,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class SkeletonText extends StatelessWidget {
  final int lines;
  final double? lineHeight;
  final double? spacing;
  final double? lastLineWidth;

  const SkeletonText({
    super.key,
    this.lines = 3,
    this.lineHeight,
    this.spacing,
    this.lastLineWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (index) {
        final isLastLine = index == lines - 1;
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < lines - 1 ? (spacing ?? 8) : 0,
          ),
          child: CustomSkeleton(
            height: lineHeight ?? 16,
            width: isLastLine && lastLineWidth != null 
                ? lastLineWidth 
                : double.infinity,
          ),
        );
      }),
    );
  }
}