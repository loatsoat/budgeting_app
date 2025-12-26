import 'package:flutter/material.dart';

class CustomTextArea extends StatelessWidget {
  final String? placeholder;
  final String? label;
  final TextEditingController? controller;
  final bool enabled;
  final String? errorText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputAction? textInputAction;

  const CustomTextArea({
    super.key,
    this.placeholder,
    this.label,
    this.controller,
    this.enabled = true,
    this.errorText,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.maxLines,
    this.minLines = 4,
    this.maxLength,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          enabled: enabled,
          onTap: onTap,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          focusNode: focusNode,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: placeholder,
            errorText: errorText,
            filled: true,
            fillColor: const Color(0xFFF3F3F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: theme.primaryColor,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}