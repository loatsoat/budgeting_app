import 'package:flutter/material.dart';

const String errorImgSrc =
    'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iODgiIGhlaWdodD0iODgiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgc3Ryb2tlPSIjMDAwIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBvcGFjaXR5PSIuMyIgZmlsbD0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIzLjciPjxyZWN0IHg9IjE2IiB5PSIxNiIgd2lkdGg9IjU2IiBoZWlnaHQ9IjU2IiByeD0iNiIvPjxwYXRoIGQ9Im0xNiA1OCAxNi0xOCAzMiAzMiIvPjxjaXJjbGUgY3g9IjUzIiBjeT0iMzUiIHI9IjciLz48L3N2Zz4KCg==';

class ImageWithFallback extends StatefulWidget {
  final String? src;
  final String? alt;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? errorWidget;

  const ImageWithFallback({
    super.key,
    this.src,
    this.alt,
    this.width,
    this.height,
    this.fit,
    this.errorWidget,
  });

  @override
  State<ImageWithFallback> createState() => _ImageWithFallbackState();
}

class _ImageWithFallbackState extends State<ImageWithFallback> {
  bool didError = false;

  void handleError() {
    setState(() {
      didError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (didError || widget.src == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: const BoxDecoration(
          color: Color(0xFFF3F4F6),
        ),
        child: widget.errorWidget ??
            const Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 48,
              ),
            ),
      );
    }

    return Image.network(
      widget.src!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit ?? BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          handleError();
        });
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: const BoxDecoration(
            color: Color(0xFFF3F4F6),
          ),
          child: const Center(
            child: Icon(
              Icons.broken_image,
              color: Colors.grey,
              size: 48,
            ),
          ),
        );
      },
    );
  }
}