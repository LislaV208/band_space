import 'package:flutter/material.dart';

extension SnackbarExtension on BuildContext {
  void showErrorSnackbar({String? message}) {
    final snackBar = SnackBar(
      backgroundColor: Theme.of(this).colorScheme.error,
      content: Text(message ?? 'Wystąpił nieoczekiwany błąd. Spróbuj ponownie'),
    );

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
