import 'package:flutter/material.dart';

class AppStreamBuilder<T> extends StatelessWidget {
  const AppStreamBuilder({
    super.key,
    required this.stream,
    required this.builder,
    this.showEmptyDataText = true,
    this.loadingWidget,
    this.errorWidget,
    this.noDataText,
    this.noDataWidget,
  });

  final Stream<T> stream;
  final Widget Function(BuildContext context, T data) builder;
  final bool showEmptyDataText;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final String? noDataText;
  final Widget? noDataWidget;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        late Widget child;

        if (snapshot.connectionState != ConnectionState.active) {
          child = Center(
            child: loadingWidget ?? const CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          print(snapshot.error);

          child = Center(
            child: errorWidget ?? const Text('Wystąpił błąd'),
          );
        } else {
          final data = snapshot.data as T;

          if (data is List && data.isEmpty && showEmptyDataText) {
            child = Center(
              child: noDataWidget ??
                  Text(
                    noDataText ?? 'Brak wyników',
                    textAlign: TextAlign.center,
                  ),
            );
          } else {
            child = builder(context, data);
          }
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.fastOutSlowIn,
          switchOutCurve: Curves.fastOutSlowIn,
          child: child,
        );

        // return builder(context, data);
      },
    );
  }
}
