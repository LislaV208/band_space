import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:band_space/song/marker_collision_validator.dart';
import 'package:band_space/song/model/marker.dart';
import 'package:band_space/song/model/marker_dto.dart';
import 'package:band_space/utils/duration_extensions.dart';
import 'package:band_space/widgets/app_button_primary.dart';

class AddEditMarkerScreen extends StatefulWidget {
  const AddEditMarkerScreen({
    super.key,
    required this.markers,
    required this.songDuration,
    this.startPosition,
    this.markerToEdit,
    required this.onAddEditMarker,
  });

  final List<Marker> markers;
  final Duration songDuration;
  final Duration? startPosition;
  final Marker? markerToEdit;

  final Future<void> Function(MarkerDTO marker) onAddEditMarker;

  @override
  State<AddEditMarkerScreen> createState() => _AddEditMarkerScreenState();
}

class _AddEditMarkerScreenState extends State<AddEditMarkerScreen> {
  final _formKey = GlobalKey<FormState>();

  late final _nameController = TextEditingController(
    text: widget.markerToEdit?.name,
  );
  late final _startPositionController = TextEditingController(
    text: widget.startPosition != null ? widget.startPosition!.inSeconds.toString() : '',
  );
  late final _endPositionController = TextEditingController(
    text: widget.markerToEdit?.end_position != null ? widget.markerToEdit!.end_position!.inSeconds.toString() : '',
  );

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
        title: Text(widget.markerToEdit == null ? 'Dodaj znacznik' : 'Edytuj znacznik'),
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

                        if (intValue > widget.songDuration.inSeconds) {
                          return 'Maksymalna wartość - ${widget.songDuration.inSeconds}';
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
                          if (intValue > widget.songDuration.inSeconds) {
                            return 'Maksymalna wartość - ${widget.songDuration.inSeconds}';
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
                    await widget.onAddEditMarker(
                      MarkerDTO(
                        name: _nameController.text,
                        startPosition: Duration(seconds: int.parse(_startPositionController.text)),
                        endPosition: _endPositionController.text.isNotEmpty
                            ? Duration(seconds: int.parse(_endPositionController.text))
                            : null,
                      ),
                    );

                    if (!mounted) return;

                    Navigator.of(context).pop();
                  }
                },
                text: widget.markerToEdit == null ? 'Dodaj' : 'Zapisz',
              ),
            ],
          ),
        ),
      ),
    );
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

    if (startPosition == 0 && endPosition == widget.songDuration.inSeconds) {
      setState(() {
        _validationMessage = 'Znacznik obejmuje cały utwór';
      });

      return false;
    }

    final collidingMarkers = MarkerCollisionValidator(
      currentMarkers: widget.markers,
      start: startPosition != null ? Duration(seconds: startPosition) : null,
      end: endPosition != null ? Duration(seconds: endPosition) : null,
    ).validate();

    if (widget.markerToEdit != null) {
      collidingMarkers.removeWhere(
        (element) =>
            element.start_position == widget.markerToEdit!.start_position &&
            element.end_position == widget.markerToEdit!.end_position,
      );
    }

    if (collidingMarkers.isNotEmpty) {
      setState(() {
        _validationMessage = _buildCollidingMarkersMessage(collidingMarkers);
      });

      return false;
    }

    return true;
  }

  String _buildCollidingMarkersMessage(List<Marker> markers) {
    final buffer = StringBuffer('Znacznik koliduje z ');
    buffer.write(markers.length > 1 ? 'innymi znacznikami: ' : 'innym znaniczkiem: ');

    for (final marker in markers) {
      buffer.write('${marker.name} (');
      if (marker.end_position == null) {
        buffer.write(marker.start_position.format());
      } else {
        buffer.write(marker.start_position.format());
        buffer.write(' - ');
        buffer.write(marker.end_position!.format());
      }
      buffer.write('), ');
    }

    final bufferString = buffer.toString();
    return bufferString.substring(0, bufferString.length - 2);
  }
}
