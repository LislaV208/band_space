import 'package:flutter/material.dart';

class AppButtonSecondary extends StatelessWidget {
  const AppButtonSecondary({
    super.key,
    required this.onTap,
    required this.text,
    this.isLoading = false,
  });

  final VoidCallback onTap;
  final String text;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 200,
        minHeight: 34,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                ),
              )
            : Text(text),
      ),
    );
  }
}
