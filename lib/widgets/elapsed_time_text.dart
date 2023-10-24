import 'dart:async';

import 'package:flutter/material.dart';

import 'package:duration/duration.dart';

class ElapsedTimeText extends StatefulWidget {
  const ElapsedTimeText({
    super.key,
    required this.dateFrom,
  });

  final DateTime dateFrom;

  @override
  State<ElapsedTimeText> createState() => _ElapsedTimeTextState();
}

class _ElapsedTimeTextState extends State<ElapsedTimeText> {
  late Timer _timer;
  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsedDuration = Duration(
      milliseconds: DateTime.now().millisecondsSinceEpoch - widget.dateFrom.millisecondsSinceEpoch,
    );
    return Text(
      elapsedDuration.inSeconds < 30
          ? 'Teraz'
          : prettyDuration(
              Duration(
                milliseconds: DateTime.now().millisecondsSinceEpoch - widget.dateFrom.millisecondsSinceEpoch,
              ),
              abbreviated: true,
            ).split(', ').first,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.white.withOpacity(0.5)),
    );
  }
}
