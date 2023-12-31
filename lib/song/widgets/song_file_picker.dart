import 'package:band_space/song/model/song_upload_data.dart';
import 'package:band_space/utils/context_extensions.dart';
import 'package:band_space/widgets/app_button_secondary.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

class SongFilePicker extends StatefulWidget {
  const SongFilePicker({
    super.key,
    required this.onFilePicked,
  });

  final void Function(SongUploadFile file) onFilePicked;

  @override
  State<SongFilePicker> createState() => _SongFilePickerState();
}

class _SongFilePickerState extends State<SongFilePicker> {
  PlatformFile? _selectedFile;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButtonSecondary(
            onTap: () => _selectFile(),
            text: _selectedFile == null ? 'Wybierz plik' : 'Zmień plik',
            isLoading: _isLoading,
          ),
          if (_selectedFile != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(_selectedFile!.name),
            ),
        ],
      ),
    );
  }

  void _selectFile() async {
    setState(() {
      _isLoading = true;
    });

    var showError = false;

    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.audio,
      initialDirectory: kIsWeb
          ? null
          : _selectedFile != null
              ? _selectedFile!.path
              : null,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final bytes = file.bytes;

      if (bytes != null) {
        final mimeType = lookupMimeType('', headerBytes: bytes);

        widget.onFilePicked(
          SongUploadFile(
            name: file.name,
            extension: file.extension ?? '',
            data: bytes,
            size: file.size,
            mimeType: mimeType ?? '',
          ),
        );

        _selectedFile = file;
      } else {
        showError = true;
      }
    }

    if (!mounted) return;

    if (showError) {
      context.showErrorSnackbar(message: 'Nie można załadować pliku');
    }

    setState(() {
      _isLoading = false;
    });
  }
}
