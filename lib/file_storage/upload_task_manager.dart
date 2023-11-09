import 'package:firebase_storage/firebase_storage.dart';

class UploadTaskManager {
  final _currentTasks = <String, UploadTask>{};

  UploadTask? getUploadTask(String id) => _currentTasks[id];

  void addUploadTask(UploadTask task) {
    _currentTasks[task.snapshot.ref.name] = task;

    task.then((snapshot) {
      _currentTasks.remove(snapshot.ref.name);
    });
  }
}
