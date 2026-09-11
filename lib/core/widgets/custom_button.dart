import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ButtonVariant { filled, outlined, text }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final Color? color;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.filled,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppColors.primary;
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label),
            ],
          );

    final style = switch (variant) {
      ButtonVariant.filled => ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: btnColor.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white70,
        ),
      ButtonVariant.outlined => OutlinedButton.styleFrom(
          foregroundColor: btnColor,
          side: BorderSide(color: btnColor),
        ),
      ButtonVariant.text => TextButton.styleFrom(
          foregroundColor: btnColor,
        ),
    };

    final button = switch (variant) {
      ButtonVariant.filled => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        ),
      ButtonVariant.outlined => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        ),
      ButtonVariant.text => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        ),
    };

    if (isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
