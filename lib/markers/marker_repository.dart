import 'package:band_space/core/firestore/firestore_collection_names.dart';
import 'package:band_space/core/firestore/firestore_repository.dart';

class MarkerRepository extends FirestoreRepository {
  final String markerId;

  const MarkerRepository({
    required super.db,
    required this.markerId,
  });

  Future<void> delete() async {
    await db.runTransaction((transaction) async {
      final markerDoc = await db.collection(FirestoreCollectionNames.markers).doc(markerId).get();

      await deleteMarker(transaction, markerDoc);
    });
  }
}
