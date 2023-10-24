import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppAlertDialog extends StatefulWidget {
  const AppAlertDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText,
    this.cancelText,
    this.iconData,
  });

  final String title;
  final String content;
  final String? confirmText;
  final String? cancelText;
  final IconData? iconData;

  @override
  State<AppAlertDialog> createState() => _AppAlertDialogState();
}

class _AppAlertDialogState extends State<AppAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter) || event.isKeyPressed(LogicalKeyboardKey.numpadEnter)) {
          Navigator.of(context).pop(true);
        }
      },
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.black),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.red.withOpacity(0.2),
                        foregroundColor: Colors.red,
                        child: Icon(
                          widget.iconData ?? Icons.warning,
                          size: 20.0,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      widget.content,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ButtonBar(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(
                            widget.cancelText ?? 'Anuluj',
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          style: FilledButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          child: Text(widget.confirmText ?? 'OK'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
