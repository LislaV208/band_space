import 'package:band_space/song/model/marker.dart';
import 'package:band_space/song/model/marker_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VersionRepository {
  final String versionId;
  final FirebaseFirestore db;

  const VersionRepository({
    required this.versionId,
    required this.db,
  });

  DocumentReference get _versionRef => db.collection('versions').doc(versionId);

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
        .collection('markers')
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
          name: data['name'],
          position: data['position'],
        );
      }).toList();
    });
  }
}
