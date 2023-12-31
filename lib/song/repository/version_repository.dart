import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:band_space/core/firestore/firestore_collection_names.dart';
import 'package:band_space/core/firestore/firestore_repository.dart';
import 'package:band_space/song/model/firebase/firebase_song_version_model.dart';
import 'package:band_space/song/model/marker.dart';
import 'package:band_space/song/model/marker_dto.dart';
import 'package:band_space/song/model/song_version_model.dart';
import 'package:band_space/song/model/version_comment.dart';
import 'package:band_space/user/model/firebase_user_model.dart';

class VersionRepository extends FirestoreRepository {
  final String versionId;
  final String userId;
  final FirebaseStorage storage;

  const VersionRepository({
    required this.versionId,
    required this.userId,
    required super.db,
    required this.storage,
  });

  DocumentReference<Map<String, dynamic>> get _versionRef =>
      db.collection(FirestoreCollectionNames.versions).doc(versionId);

  Stream<SongVersionModel> get() {
    return _versionRef.snapshots().asyncMap(
      (doc) async {
        final currentVersionQuery = await db
            .collection(FirestoreCollectionNames.songs)
            .where('current_version', isEqualTo: doc.reference)
            .count()
            .get();
        final isVersionCurrent = currentVersionQuery.count > 0;

        return FirebaseSongVersionModel.create(doc: doc, isCurrent: isVersionCurrent);
      },
    );
  }

  Future<VersionComment> addComment(String text, Duration? startPosition, Duration? endPosition) async {
    final userRef = db.collection('users').doc(userId);

    final commentRef = _versionRef.collection(FirestoreCollectionNames.comments).doc();
    final timestamp = Timestamp.now();
    await commentRef.set({
      'created_at': Timestamp.now(),
      'author': userRef,
      'text': text,
      'start_position': startPosition?.inMilliseconds,
      'end_position': endPosition?.inMilliseconds,
    });

    final userDoc = await userRef.get();

    return VersionComment(
      id: commentRef.id,
      created_at: timestamp.toDate(),
      author: FirebaseUserModel.fromDocument(userDoc),
      text: text,
      start_position: startPosition,
    );
  }

  Future<VersionComment> editComment(String id, String text, Duration? startPosition, Duration? endPosition) async {
    final commentRef = _versionRef.collection(FirestoreCollectionNames.comments).doc(id);
    await commentRef.update({
      'text': text,
      'start_position': startPosition?.inMilliseconds,
    });

    final userRef = db.collection('users').doc(userId);
    final userDoc = await userRef.get();

    final snapshot = await commentRef.get();
    final data = snapshot.data();

    return VersionComment(
      id: commentRef.id,
      created_at: data?['created_at'] != null ? (data!['created_at'] as Timestamp).toDate() : null,
      author: FirebaseUserModel.fromDocument(userDoc),
      text: data?['text'] ?? '',
      start_position: data?['start_position'] != null ? Duration(milliseconds: data!['start_position']) : null,
    );
  }

  Stream<List<VersionComment>> getComments() {
    return _versionRef
        .collection(FirestoreCollectionNames.comments)
        .orderBy('created_at')
        .snapshots()
        .asyncMap((event) async {
      return await Future.wait(event.docs.map((doc) async {
        final data = doc.data();
        final userRef = data['author'] as DocumentReference<Map<String, dynamic>>;

        final userDoc = await userRef.get();

        return VersionComment(
          id: doc.id,
          created_at: data['created_at'] != null ? (data['created_at'] as Timestamp).toDate() : null,
          author: FirebaseUserModel.fromDocument(userDoc),
          text: data['text'] ?? '',
          start_position: data['start_position'] != null ? Duration(milliseconds: data['start_position']) : null,
        );
      }));
    });
  }

  Future<void> deleteComment(String id) async {
    await _versionRef.collection(FirestoreCollectionNames.comments).doc(id).delete();
  }

  Future<void> addMarker(
    MarkerDTO markerData,
  ) async {
    final newMarkerDoc = db.collection('markers').doc();

    await newMarkerDoc.set({
      'version': _versionRef,
      'name': markerData.name,
      'start_position': markerData.startPosition.inMilliseconds,
      'end_position': markerData.endPosition != null ? markerData.endPosition!.inMilliseconds : null,
    });
  }

  Stream<List<Marker>> getMarkers() {
    final markersQueryStream = db
        .collection(FirestoreCollectionNames.markers)
        .where(
          'version',
          isEqualTo: _versionRef,
        )
        .orderBy('start_position')
        .snapshots();

    return markersQueryStream.map((query) {
      return query.docs.map((doc) {
        final data = doc.data();
        return Marker(
          id: doc.id,
          name: data['name'],
          start_position: Duration(milliseconds: data['start_position'] ?? 0),
          end_position: data['end_position'] != null ? Duration(milliseconds: data['end_position']) : null,
        );
      }).toList();
    });
  }

  //TODO: sprawdzić usuwanie bo nie działa jak trzeba
  Future<void> delete() async {
    final filesToRemove = <String>[];

    await db.runTransaction((transaction) async {
      filesToRemove.addAll(
        await deleteVersion(transaction, await _versionRef.get()),
      );

      final latestVersionDocs =
          (await db.collection(FirestoreCollectionNames.versions).orderBy('timestamp', descending: true).limit(2).get())
              .docs;

      final latestVersionDoc = latestVersionDocs.isNotEmpty
          ? latestVersionDocs.length > 1
              ? latestVersionDocs[1]
              : latestVersionDocs.first
          : null;

      final songQuery = await db
          .collection(FirestoreCollectionNames.songs)
          .where(
            'current_version',
            isEqualTo: _versionRef,
          )
          .get();

      for (final doc in songQuery.docs) {
        transaction.update(doc.reference, {'current_version': latestVersionDoc?.reference});
      }
    });

    for (final path in filesToRemove) {
      await storage.ref(path).delete();
    }
  }
}
