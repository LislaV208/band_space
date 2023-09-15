import 'dart:async';

import 'package:flutter/material.dart';

class AppButtonPrimary extends StatefulWidget {
  const AppButtonPrimary({
    super.key,
    required this.onPressed,
    required this.text,
  });

  final FutureOr<void> Function()? onPressed;
  final String text;

  @override
  State<AppButtonPrimary> createState() => _AppButtonPrimaryState();
}

class _AppButtonPrimaryState extends State<AppButtonPrimary> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: FilledButton(
        onPressed: _isLoading
            ? null
            : widget.onPressed != null
                ? () async {
                    setState(() {
                      _isLoading = true;
                    });

                    await widget.onPressed?.call();

                    // await Future.delayed(const Duration(milliseconds: 300));

                    setState(() {
                      _isLoading = false;
                    });
                  }
                : null,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 3.0,
                ),
              )
            : Text(
                widget.text,
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
