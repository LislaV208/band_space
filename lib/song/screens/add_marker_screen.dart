import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/model/marker_dto.dart';
import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/repository/version_repository.dart';
import 'package:band_space/widgets/app_button_primary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddMarkerScreen extends StatefulWidget {
  const AddMarkerScreen({
    super.key,
    required this.version,
  });

  final SongVersionModel version;

  @override
  State<AddMarkerScreen> createState() => _AddMarkerScreenState();
}

class _AddMarkerScreenState extends State<AddMarkerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _positionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj znacznik'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nazwa',
                  hintText: 'Np. zwrotka, refren, outro',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Podaj nazwę';

                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Pozycja (sekunda)',
                  hintText: 'W której sekundzie chcesz umieścić znacznik?',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Podaj wartość';

                  final intValue = int.tryParse(value);
                  if (intValue == null) return 'Nieprawidłowa wartość (tylko liczby)';

                  final songDuration = widget.version.file?.duration;
                  if (songDuration != null) {
                    if (intValue > songDuration) return 'Maksymalna wartość dla tego utworu wynosi $songDuration';
                  }

                  return null;
                },
              ),
              const Spacer(),
              AppButtonPrimary(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await sl<VersionRepository>(param1: widget.version.id).addMarker(
                      MarkerDTO(
                        name: _nameController.text,
                        position: int.parse(_positionController.text),
                      ),
                    );

                    if (!mounted) return;

                    Navigator.of(context).pop();
                  }
                },
                text: 'Dodaj',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
