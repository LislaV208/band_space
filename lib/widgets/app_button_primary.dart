import 'package:flutter/material.dart';

class AppButtonPrimary extends StatelessWidget {
  const AppButtonPrimary({
    super.key,
    required this.onTap,
    required this.text,
    this.isLoading = false,
  });

  final VoidCallback? onTap;
  final String text;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: FilledButton(
        onPressed: isLoading ? null : onTap,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                ),
              )
            : Text(
                text,
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
