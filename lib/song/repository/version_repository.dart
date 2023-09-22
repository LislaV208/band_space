import 'package:band_space/core/firestore/firestore_collection_names.dart';
import 'package:band_space/core/firestore/firestore_repository.dart';
import 'package:band_space/song/model/marker.dart';
import 'package:band_space/song/model/marker_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VersionRepository extends FirestoreRepository {
  final String versionId;

  const VersionRepository({
    required super.db,
    required this.versionId,
  });

  DocumentReference get _versionRef => db.collection(FirestoreCollectionNames.versions).doc(versionId);

  Future<void> addMarker(
    MarkerDTO markerData,
  ) async {
    final newMarkerDoc = db.collection('markers').doc();

    await newMarkerDoc.set({
      'version': _versionRef,
      'name': markerData.name,
      'position': markerData.position,
    });
  }

  Stream<List<Marker>> getMarkers() {
    final markersQueryStream = db
        .collection(FirestoreCollectionNames.markers)
        .where(
          'version',
          isEqualTo: _versionRef,
        )
        .orderBy('position')
        .snapshots();

    return markersQueryStream.map((query) {
      return query.docs.map((doc) {
        final data = doc.data();
        return Marker(
          id: doc.id,
          name: data['name'],
          position: data['position'],
        );
      }).toList();
    });
  }
}
