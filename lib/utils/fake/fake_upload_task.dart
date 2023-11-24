import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';

// Assuming the necessary imports and definitions are present,
// including FirebaseStorage, TaskSnapshot, etc.

class FakeTaskSnapshot implements TaskSnapshot {
  final FirebaseStorage _storage;
  final int _bytesTransferred;
  final int _totalBytes;
  final TaskState _state;

  FakeTaskSnapshot(this._storage, this._bytesTransferred, this._totalBytes, this._state);

  @override
  FirebaseStorage get storage => _storage;

  @override
  int get bytesTransferred => _bytesTransferred;

  @override
  FullMetadata? get metadata => null; // You can implement fake metadata if needed

  @override
  Reference get ref => throw UnimplementedError();

  @override
  TaskState get state => _state;

  @override
  int get totalBytes => _totalBytes;

  @override
  int get hashCode => Object.hash(storage, bytesTransferred, totalBytes, state);

  @override
  bool operator ==(Object other) =>
      other is FakeTaskSnapshot &&
      other.bytesTransferred == bytesTransferred &&
      other.totalBytes == totalBytes &&
      other.storage == storage &&
      other.state == state;

  @override
  String toString() => 'FakeTaskSnapshot(bytesTransferred: $bytesTransferred, totalBytes: $totalBytes, state: $state)';
}

class FakeUploadTask implements UploadTask {
  final StreamController<TaskSnapshot> _controller;
  Timer? _timer;
  int _bytesTransferred = 0;
  final int _totalBytes;
  @override
  FirebaseStorage get storage => FirebaseStorage.instance;
  TaskState _state = TaskState.running;

  FakeUploadTask(this._totalBytes) : _controller = StreamController<TaskSnapshot>() {
    _startFakeUpload();
  }

  void _startFakeUpload() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _bytesTransferred += 50000; // Increment fake bytes transferred
      if (_bytesTransferred > _totalBytes) {
        _bytesTransferred = _totalBytes;
        _state = TaskState.success;
      }

      _controller.add(FakeTaskSnapshot(storage, _bytesTransferred, _totalBytes, _state));

      if (_bytesTransferred == _totalBytes) {
        _timer?.cancel();
      }
    });
  }

  @override
  Stream<TaskSnapshot> get snapshotEvents => _controller.stream;

  @override
  TaskSnapshot get snapshot => FakeTaskSnapshot(storage, _bytesTransferred, _totalBytes, _state);

  @override
  Future<bool> pause() async {
    _timer?.cancel();
    _state = TaskState.paused;
    return true;
  }

  @override
  Future<bool> resume() async {
    if (_state == TaskState.paused) {
      _state = TaskState.running;
      _startFakeUpload();
    }
    return true;
  }

  @override
  Future<bool> cancel() async {
    _timer?.cancel();
    _controller.close();
    _state = TaskState.canceled;
    return true;
  }

  // Future-related methods implementations

  @override
  Stream<TaskSnapshot> asStream() => _controller.stream;

  @override
  Future<TaskSnapshot> catchError(Function onError, {bool Function(Object error)? test}) async {
    // Implement logic for catchError if necessary
    return snapshot;
  }

  @override
  Future<S> then<S>(FutureOr<S> Function(TaskSnapshot) onValue, {Function? onError}) {
    // Implement logic for then if necessary
    return Future.value(onValue(snapshot));
  }

  @override
  Future<TaskSnapshot> whenComplete(FutureOr Function() action) async {
    await action();
    return snapshot;
  }

  @override
  Future<TaskSnapshot> timeout(Duration timeLimit, {FutureOr<TaskSnapshot> Function()? onTimeout}) {
    return _controller.stream.timeout(timeLimit, onTimeout: null).last;
  }
}
