import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:band_space/song/model/song_model.dart';
import 'package:band_space/utils/file_size.dart';

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
        final bytesTransfered = FileSize.bytes(task?.bytesTransferred ?? 0);
        final totalBytes = FileSize.bytes(task?.totalBytes ?? 0);

        final progressValue = bytesTransfered.bytes / totalBytes.bytes;
        final progressPercentage = (progressValue * 100).toInt();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: progressValue,
                  ),
                  Text(
                    '$progressPercentage%',
                    style: const TextStyle(
                      fontWeight: FontWeight.w100,
                      fontSize: 11.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  Text(
                    'Przesłano ${bytesTransfered.megabytes.toStringAsFixed(2)} z ${totalBytes.megabytes.toStringAsFixed(2)} MB',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
