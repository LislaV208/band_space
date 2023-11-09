import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:band_space/song/model/song_model.dart';

class UploadingSongListTile extends StatelessWidget {
  const UploadingSongListTile({
    super.key,
    required this.song,
    required this.uploadTask,
  });

  final SongModel song;
  final UploadTask uploadTask;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      initialData: uploadTask.snapshot,
      stream: uploadTask.snapshotEvents,
      builder: (context, snapshot) {
        final task = snapshot.data;
        final bytesTransfered = task?.bytesTransferred ?? 0;
        final totalBytes = task?.totalBytes ?? -1;

        final progressValue = bytesTransfered / totalBytes;
        final progressPercentage = (progressValue * 100).toInt();

        return ListTile(
          leading: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progressValue,
              ),
              Text('$progressPercentage%'),
            ],
          ),
          title: Text(
            song.title,
          ),
          subtitle: Text(
            'Przesłano ${_bytesToMegabytesString(bytesTransfered)} z ${_bytesToMegabytesString(totalBytes)}',
          ),
        );
      },
    );
  }

  String _bytesToMegabytesString(int bytes) {
    final megabytes = bytes / 1024 / 1024;

    return '${megabytes.toStringAsFixed(2)} MB';
  }
}
