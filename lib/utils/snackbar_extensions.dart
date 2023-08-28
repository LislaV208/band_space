import 'package:flutter/material.dart';

extension SnackbarExtension on BuildContext {
  void showErrorSnackbar() {
    final snackBar = SnackBar(
      backgroundColor: Theme.of(this).colorScheme.error,
      content: const Text('Wystąpił nieoczekiwany błąd. Spróbuj ponownie'),
    );

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
