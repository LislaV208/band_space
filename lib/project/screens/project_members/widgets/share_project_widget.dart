import 'package:band_space/utils/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShareProjectWidget extends StatefulWidget {
  const ShareProjectWidget({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  State<ShareProjectWidget> createState() => _ShareProjectWidgetState();
}

class _ShareProjectWidgetState extends State<ShareProjectWidget> {
  final _linkController = TextEditingController();

  @override
  void initState() {
    super.initState();

    //TODO: app url from env
    const appUrl = 'https://band-space-317b6.web.app';
    // const appUrl = 'localhost:61801';

    _linkController.text = '$appUrl/invite?project=${widget.projectId}';
  }

  @override
  void dispose() {
    _linkController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Zaproś do projektu',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _linkController,
                readOnly: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: IconButton(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: _linkController.text),
                  );

                  if (!mounted) return;

                  context.showSnackbar('Skopiowano do schowka');
                },
                icon: const Icon(
                  Icons.copy,
                ),
                tooltip: 'Kopiuj do schowka',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
