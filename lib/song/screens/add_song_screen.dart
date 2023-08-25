import 'dart:developer';

import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/repository/song_repository.dart';
import 'package:flutter/material.dart';

class AddSongScreen extends StatefulWidget {
  const AddSongScreen({super.key});

  @override
  State<AddSongScreen> createState() => _AddSongScreenState();
}

class _AddSongScreenState extends State<AddSongScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nowy utwór'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nazwa',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Wybierz plik'),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final name = _nameController.text;
                        if (name.isNotEmpty) {
                          // final song =
                          //     await sl.get<SongRepository>().createSong(name);

                          // if (!mounted) return;

                          // if (song != null) {
                          //   log('Dodano nowy utwór: ${song.name}');
                          //   Navigator.of(context).pop();
                          // } else {
                          //   log('Wystąpił błąd podczas dodawania utwory');
                          // }
                        }
                      },
                      label: Text(
                        'Dodaj utwór',
                      ),
                      icon: Icon(Icons.add),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
