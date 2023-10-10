import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:band_space/core/firestore/firestore_collection_names.dart';
import 'package:band_space/core/firestore/firestore_repository.dart';
import 'package:band_space/song/model/firebase/firebase_song_version_model.dart';
import 'package:band_space/song/model/marker.dart';
import 'package:band_space/song/model/marker_dto.dart';
import 'package:band_space/song/model/song_version_model.dart';

class VersionRepository extends FirestoreRepository {
  final String versionId;
  final FirebaseStorage storage;

  const VersionRepository({
    required this.versionId,
    required super.db,
    required this.storage,
  });

  DocumentReference get _versionRef => db.collection(FirestoreCollectionNames.versions).doc(versionId);

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

  Future<void> addMarker(
    MarkerDTO markerData,
  ) async {
    final newMarkerDoc = db.collection('markers').doc();

    await newMarkerDoc.set({
      'version': _versionRef,
      'name': markerData.name,
      'start_position': markerData.startPosition,
      'end_position': markerData.endPosition,
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
          start_position: data['start_position'],
          end_position: data['end_position'],
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
