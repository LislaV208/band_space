import 'package:firebase_storage/firebase_storage.dart';

import 'package:band_space/file_storage/upload_task_manager.dart';
import 'package:band_space/song/model/song_upload_data.dart';

class RemoteSongFileStorage {
  final FirebaseStorage storage;
  final UploadTaskManager uploadTaskManager;

  const RemoteSongFileStorage({
    required this.storage,
    required this.uploadTaskManager,
  });

  void upload({
    required String name,
    required SongUploadFile file,
    void Function(TaskSnapshot snapshot)? onComplete,
  }) {
    final storageRef = storage.ref('audio').child(name);
    final uploadTask = storageRef.putData(
      file.data,
      SettableMetadata(
        contentType: file.mimeType,
      ),
    );

    uploadTask.then((snapshot) => onComplete?.call(snapshot));
    uploadTaskManager.addUploadTask(uploadTask);
  }
}
