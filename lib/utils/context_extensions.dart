import 'package:flutter/material.dart';

extension SnackbarExtension on BuildContext {
  void showSnackbar(String text) {
    final snackBar = SnackBar(
      content: Text(text),
    );

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

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

extension MediaQueryExtension on BuildContext {
  bool get useBottomNavigation => MediaQuery.of(this).size.width < 900;
}
