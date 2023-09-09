import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:band_space/song/screens/add_song/add_song_state.dart';
import 'package:band_space/song/song_state.dart';
import 'package:band_space/song/widgets/song_file_picker.dart';
import 'package:band_space/utils/context_extensions.dart';
import 'package:band_space/widgets/app_button_primary.dart';

class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AddSongState>();

    return WillPopScope(
      onWillPop: () async => state.canPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dodaj utwór'),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    TextFormField(
                      autofocus: true,
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tytuł',
                        hintText: 'Jak nazywa się nowy utwór?',
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Podaj tytuł' : null,
                    ),
                    const SizedBox(height: 20),
                    SongFilePicker(
                      onFilePicked: (file) {
                        state.onFileSelected(file);
                      },
                    ),
                    const SizedBox(height: 40),
                    const Divider(),
                    const SizedBox(height: 20),
                    Text('Określ stan utworu'),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 20,
                      children: [
                        _buildChoiceChip(
                          label: 'Szkic',
                          state: state,
                          songState: SongState.draft,
                        ),
                        _buildChoiceChip(
                          label: 'Demo',
                          state: state,
                          songState: SongState.demo,
                        ),
                        _buildChoiceChip(
                          label: 'Finalny',
                          state: state,
                          songState: SongState.finalVersion,
                        ),
                      ],
                    ),
                  ],
                ),
                AppButtonPrimary(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      final songId = await state.addSong(
                        widget.projectId,
                        _titleController.text,
                      );

                      if (!mounted) return;

                      if (songId != null) {
                        context.pop();
                        context.goNamed(
                          'song',
                          pathParameters: {
                            'project_id': widget.projectId,
                            'song_id': songId,
                          },
                        );
                      } else {
                        context.showErrorSnackbar();
                      }
                    }
                  },
                  text: 'Dodaj',
                  isLoading: state.addingSong,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required AddSongState state,
    required SongState songState,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: state.songState == songState,
      onSelected: (isSelected) {
        if (isSelected) {
          state.onSongStateSelected(songState);
        }
      },
    );
  }
}
