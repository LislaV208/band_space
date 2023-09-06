import 'package:flutter/material.dart';

class AppButtonSecondary extends StatelessWidget {
  const AppButtonSecondary({
    super.key,
    required this.onTap,
    required this.text,
    this.isLoading = false,
    this.icon,
    this.color,
  });

  final VoidCallback onTap;
  final String text;
  final bool isLoading;
  final Icon? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final onPressed = isLoading ? null : onTap;
    final child = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 3.0,
            ),
          )
        : Text(
            text,
            style: TextStyle(color: color),
          );

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 210,
        minHeight: 40,
      ),
      child: icon != null
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: icon!,
              label: child,
            )
          : ElevatedButton(
              onPressed: onPressed,
              child: child,
            ),
    );
  }
}
