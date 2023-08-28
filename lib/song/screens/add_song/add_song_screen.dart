import 'package:band_space/song/screens/add_song/add_song_state.dart';
import 'package:band_space/utils/snackbar_extensions.dart';
import 'package:band_space/widgets/app_button_primary.dart';
import 'package:band_space/widgets/app_button_secondary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key, required this.projectId});

  final String projectId;

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _tempoController = TextEditingController();
  final _lyricsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _tempoController.dispose();
    _lyricsController.dispose();

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
                    AppButtonSecondary(
                      onTap: () => state.selectFile(),
                      text: state.selectedFile == null
                          ? 'Wybierz plik'
                          : 'Zmień plik',
                      isLoading: state.openingFilePicker,
                    ),
                    if (state.selectedFile != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(state.selectedFile!.name),
                      ),
                    const SizedBox(height: 40),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Dodatkowe informacje',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Divider(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _tempoController,
                      decoration: const InputDecoration(
                        labelText: 'Tempo (BPM)',
                        hintText: 'Wprowadź wartość od 40 do 240 BPM',
                        counter: SizedBox(),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      maxLength: 3,
                      validator: (value) {
                        final tempo = int.tryParse(value!);
                        if (tempo != null && (tempo < 40 || tempo > 240)) {
                          return 'Podaj wartość między 40 BPM a 240 BPM';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _lyricsController,
                      decoration: const InputDecoration(
                        labelText: 'Tekst',
                        hintText: 'Wprowadź tekst utworu',
                        alignLabelWithHint: true,
                      ),
                      minLines: 10,
                      maxLines: 10,
                    )
                  ],
                ),
                AppButtonPrimary(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      final songId = await state.addSong(
                        widget.projectId,
                        _titleController.text,
                        _tempoController.text,
                        _lyricsController.text,
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
}
