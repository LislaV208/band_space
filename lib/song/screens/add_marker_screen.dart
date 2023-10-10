import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:band_space/core/service_locator.dart';
import 'package:band_space/song/marker_collision_validator.dart';
import 'package:band_space/song/model/marker.dart';
import 'package:band_space/song/model/marker_dto.dart';
import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/repository/version_repository.dart';
import 'package:band_space/utils/duration_extensions.dart';
import 'package:band_space/widgets/app_button_primary.dart';

class AddMarkerScreen extends StatefulWidget {
  const AddMarkerScreen({
    super.key,
    required this.markers,
    required this.version,
    required this.currentPosition,
  });

  final List<Marker> markers;
  final SongVersionModel version;
  final int currentPosition;

  @override
  State<AddMarkerScreen> createState() => _AddMarkerScreenState();
}

class _AddMarkerScreenState extends State<AddMarkerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  late final _startPositionController =
      TextEditingController(text: widget.currentPosition > 0 ? widget.currentPosition.toString() : null);
  final _endPositionController = TextEditingController();

  var _validationMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _startPositionController.dispose();
    _endPositionController.dispose();

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
                autofocus: true,
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startPositionController,
                      decoration: const InputDecoration(
                        labelText: 'Początek',
                        hintText: 'Wartość w sekundach',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Podaj wartość';

                        final intValue = int.tryParse(value);
                        if (intValue == null) return 'Nieprawidłowa wartość (tylko liczby)';

                        final songDuration = widget.version.file?.duration;
                        if (songDuration != null) {
                          if (intValue > songDuration) return 'Maksymalna wartość - $songDuration';
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      controller: _endPositionController,
                      decoration: const InputDecoration(
                        labelText: 'Koniec (opcjonalnie)',
                        hintText: 'Wartość w sekundach',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        final intValue = int.tryParse(value ?? '');
                        if (value != null && value.isNotEmpty && intValue == null) {
                          return 'Nieprawidłowa wartość (tylko liczby)';
                        }

                        if (intValue != null) {
                          final songDuration = widget.version.file?.duration;
                          if (songDuration != null) {
                            if (intValue > songDuration) {
                              return 'Maksymalna wartość - $songDuration';
                            }
                          }
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),
              if (_validationMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    _validationMessage,
                    // style: errorStyle, //TODO: add error style
                  ),
                ),
              const Spacer(),
              AppButtonPrimary(
                onPressed: () async {
                  if (_validate()) {
                    await sl<VersionRepository>(param1: widget.version.id).addMarker(
                      MarkerDTO(
                        name: _nameController.text,
                        startPosition: int.parse(_startPositionController.text),
                        endPosition: int.tryParse(_endPositionController.text),
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

  String _buildCollidingMarkersMessage(List<Marker> markers) {
    final buffer = StringBuffer('Znacznik koliduje z ');
    buffer.write(markers.length > 1 ? 'innymi znacznikami: ' : 'innym znaniczkiem: ');

    for (final marker in markers) {
      buffer.write('${marker.name} (');
      if (marker.end_position == null) {
        buffer.write(Duration(seconds: marker.start_position).format());
      } else {
        buffer.write(Duration(seconds: marker.start_position).format());
        buffer.write(' - ');
        buffer.write(Duration(seconds: marker.end_position!).format());
      }
      buffer.write('), ');
    }

    final bufferString = buffer.toString();
    return bufferString.substring(0, bufferString.length - 2);
  }

  bool _validate() {
    final isFormValid = _formKey.currentState!.validate();
    if (!isFormValid) {
      return false;
    }

    return _additionalValidation();
  }

  bool _additionalValidation() {
    final startPosition = int.tryParse(_startPositionController.text);
    final endPosition = int.tryParse(_endPositionController.text);

    if (startPosition != null && endPosition != null) {
      if (startPosition > endPosition) {
        setState(() {
          _validationMessage = 'Początek nie moze być później od końca';
        });

        return false;
      }
    }

    if (startPosition == 0 && endPosition == widget.version.file?.duration) {
      setState(() {
        _validationMessage = 'Znacznik obejmuje cały utwór';
      });

      return false;
    }

    final collidingMarkers = MarkerCollisionValidator(
      currentMarkers: widget.markers,
      start: startPosition,
      end: endPosition,
    ).validate();

    if (collidingMarkers.isNotEmpty) {
      setState(() {
        _validationMessage = _buildCollidingMarkersMessage(collidingMarkers);
      });

      return false;
    }

    return true;
  }
}
