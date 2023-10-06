import 'package:flutter/material.dart';

class AppStreamBuilder<T> extends StatelessWidget {
  const AppStreamBuilder({
    super.key,
    required this.stream,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
    this.noDataText,
  });

  final Stream<T> stream;
  final Widget Function(BuildContext context, T data) builder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final String? noDataText;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return Center(
            child: loadingWidget ?? const CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: errorWidget ?? const Text('Wystąpił błąd'),
          );
        }

        final data = snapshot.data as T;

        if (data is List) {
          if (data.isEmpty) {
            return Center(
              child: Text(
                noDataText ?? 'Brak wyników',
                textAlign: TextAlign.center,
              ),
            );
          }
        }

        return builder(context, data);
      },
    );
  }
}
