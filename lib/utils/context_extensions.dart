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

extension ContextMenuExtension on BuildContext {
  void showContextMenu({required Offset globalPosition, required List<PopupMenuEntry<String>> items}) {
    final overlay = Overlay.of(this).context.findRenderObject() as RenderBox;
    // TODO: uzyć szerokości bocznego paneul zamiast zahardcodowanej wartości
    final dxOffset = useBottomNavigation ? 0.0 : 265.0;

    showMenu(
      context: this,
      position: RelativeRect.fromRect(
        globalPosition & const Size(0, 0),
        Offset(dxOffset, 0) & overlay.size,
      ),
      items: items,
    );
  }
}

extension DialogExtension on BuildContext {
  Future<T?> showDialog<T>({required Widget dialog}) {
    return showGeneralDialog<T>(
      context: this,
      pageBuilder: (context, a1, a2) => dialog,
      barrierDismissible: true,
      barrierLabel: 'Anuluj',
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, a1, a2, widget) {
        final curvedValue = Curves.easeInOutBack.transform(a1.value) - 1.0;

        return Transform(
          transform: Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
          child: Opacity(
            opacity: a1.value,
            child: widget,
          ),
        );
      },
    );
  }
}
