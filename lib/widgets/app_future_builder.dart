import 'package:flutter/material.dart';

class AppFutureBuilder<T> extends StatelessWidget {
  const AppFutureBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
    this.noDataText,
  });

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final String? noDataText;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            // child: loadingWidget ?? const CircularProgressIndicator(),
            child: loadingWidget ?? const SizedBox(),
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
