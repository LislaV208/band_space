import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/model/song_upload_data.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:band_space/song/widgets/song_file_picker.dart';
import 'package:band_space/widgets/app_button_primary.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NewSongVersionScreen extends StatefulWidget {
  const NewSongVersionScreen({
    super.key,
    required this.projectId,
    required this.songId,
    required this.onFinished,
  });

  final String projectId;
  final String songId;
  final VoidCallback onFinished;

  @override
  State<NewSongVersionScreen> createState() => _NewSongVersionScreenState();
}

class _NewSongVersionScreenState extends State<NewSongVersionScreen> {
  final _commentController = TextEditingController();

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
            Expanded(
              child: Align(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: 'Komentarz',
                    hintText: 'Dodaj krótki opis co zmieniło się w nowej wersji',
                  ),
                ),
              ),
            ),
            AppButtonPrimary(
              onPressed: _uploadFile == null
                  ? null
                  : () async {
                      await sl<SongRepository>(param1: widget.songId).addVersion(
                        widget.projectId,
                        _uploadFile!,
                        _commentController.text,
                      );

                      widget.onFinished();

                      if (!mounted) return;

                      context.pop();
                    },
              text: 'Dodaj',
            ),
          ],
        ),
      ),
    );
  }
}
