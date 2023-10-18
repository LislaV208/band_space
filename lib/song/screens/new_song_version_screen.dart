import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:band_space/song/model/song_upload_data.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/song/widgets/song_file_picker.dart';
import 'package:band_space/widgets/app_button_primary.dart';

class NewSongVersionScreen extends StatefulWidget {
  const NewSongVersionScreen({
    super.key,
    required this.canCopyMarkers,
  });

  final bool canCopyMarkers;

  @override
  State<NewSongVersionScreen> createState() => _NewSongVersionScreenState();
}

class _NewSongVersionScreenState extends State<NewSongVersionScreen> {
  final _commentController = TextEditingController();

  var _copyMarkers = false;
  var _keepMarkersComments = false;
  SongUploadFile? _uploadFile;

  @override
  void dispose() {
    _commentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nowa wersja'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Align(
                child: SongFilePicker(
                  onFilePicked: (file) {
                    setState(() {
                      _uploadFile = file;
                    });
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  labelText: 'Komentarz',
                  hintText: 'Dodaj krótki opis co zmieniło się w nowej wersji',
                ),
              ),
            ),
            if (widget.canCopyMarkers)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SwitchListTile(
                  title: const Text('Kopiuj znaczniki'),
                  secondary: const Icon(Icons.copy),
                  value: _copyMarkers,
                  onChanged: (value) {
                    setState(() {
                      _copyMarkers = value;
                    });
                  },
                ),
              ),
            if (widget.canCopyMarkers)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SwitchListTile(
                  title: Text(
                    'Zachowaj komentarze znaczników',
                    style: !_copyMarkers
                        ? const TextStyle(
                            color: Colors.grey,
                          )
                        : null,
                  ),
                  secondary: Icon(
                    Icons.message,
                    color: !_copyMarkers ? Colors.grey : null,
                  ),
                  value: !_copyMarkers ? false : _keepMarkersComments,
                  onChanged: !_copyMarkers
                      ? null
                      : (value) {
                          setState(() {
                            _keepMarkersComments = value;
                          });
                        },
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: AppButtonPrimary(
                onPressed: _uploadFile == null
                    ? null
                    : () async {
                        final newVersion = await context.read<SongRepository>().addVersion(
                              _uploadFile!,
                              _commentController.text,
                              _copyMarkers,
                              _keepMarkersComments,
                            );

                        if (!mounted) return;

                        Navigator.of(context).pop(newVersion);
                      },
                text: 'Dodaj',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
