import 'dart:developer';

import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  final _titleController = TextEditingController();

  PlatformFile? _selectedFile;

  var _isAdding = false;

  @override
  void dispose() {
    _titleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isAdding,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dodaj utwór'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      TextField(
                        autofocus: true,
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Tytuł',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(
                            withData: true,
                            type: FileType.audio,
                            initialDirectory: _selectedFile != null
                                ? _selectedFile!.path
                                : null,
                          );
                          if (result != null && result.files.isNotEmpty) {
                            final file = result.files.first;

                            if (file.bytes == null || file.bytes!.isEmpty) {
                              log('BRAK BYTESÓW');
                            }

                            setState(() {
                              _selectedFile = file;
                            });
                          }
                        },
                        child: Text(
                          _selectedFile == null
                              ? 'Wybierz plik'
                              : 'Wybierz inny plik',
                        ),
                      ),
                      if (_selectedFile != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(_selectedFile!.name),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: FilledButton(
                        onPressed: _isAdding
                            ? null
                            : () async {
                                final title = _titleController.text;
                                if (title.isNotEmpty && _selectedFile != null) {
                                  setState(() {
                                    _isAdding = true;
                                  });

                                  final songId = await sl
                                      .get<SongRepository>()
                                      .addSong(widget.projectId, title,
                                          _selectedFile!);

                                  if (!mounted) return;

                                  context.pop();

                                  context.pushNamed(
                                    'song',
                                    pathParameters: {
                                      'project_id': widget.projectId,
                                      'song_id': songId,
                                    },
                                  );
                                }
                              },
                        child: _isAdding
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3.0,
                                ),
                              )
                            : Text(
                                'Dodaj',
                              ),
                      ),
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
