import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:band_space/core/firestore/firestore_collection_names.dart';
import 'package:band_space/song/model/version_file_model.dart';

abstract class FirestoreRepository {
  final FirebaseFirestore db;

  const FirestoreRepository({
    required this.db,
  });

  Future<List<String>> deleteProject(Transaction transaction, DocumentReference projectRef) async {
    final pathsOfFilesToRemove = await deleteAllSongs(transaction, projectRef);

    transaction.delete(projectRef);

    return pathsOfFilesToRemove;
  }

  Future<List<String>> deleteAllSongs(Transaction transaction, DocumentReference projectRef) async {
    final pathsOfFilesToRemove = <String>[];

    final songsResult = await db
        .collection(FirestoreCollectionNames.songs)
        .where(
          'project',
          isEqualTo: projectRef,
        )
        .get();

    for (final songDoc in songsResult.docs) {
      pathsOfFilesToRemove.addAll(
        await deleteSong(transaction, songDoc.reference),
      );
    }

    return pathsOfFilesToRemove;
  }

  Future<List<String>> deleteSong(Transaction transaction, DocumentReference songRef) async {
    final pathsOfFilesToRemove = await deleteAllVersions(transaction, songRef);

    transaction.delete(songRef);

    return pathsOfFilesToRemove;
  }

  Future<List<String>> deleteAllVersions(Transaction transaction, DocumentReference songRef) async {
    final versionsResult = await db
        .collection(FirestoreCollectionNames.versions)
        .where(
          'song',
          isEqualTo: songRef,
        )
        .get();

    final pathsOfFilesToRemove = <String>[];

    for (final versionDoc in versionsResult.docs) {
      pathsOfFilesToRemove.addAll(
        await deleteVersion(transaction, versionDoc),
      );
    }

    return pathsOfFilesToRemove;
  }

  Future<List<String>> deleteVersion(Transaction transaction, DocumentSnapshot versionDoc) async {
    final pathsOfFilesToRemove = <String>[];

    final file = versionDoc['file'] != null
        ? VersionFileModel.fromMap(
            versionDoc['file'],
          )
        : null;
    final path = file?.storage_path;

    if (path != null) {
      pathsOfFilesToRemove.add(path);
    }

    final commentsResult = await versionDoc.reference.collection('comments').get();
    for (final commentDoc in commentsResult.docs) {
      transaction.delete(commentDoc.reference);
    }

    transaction.delete(versionDoc.reference);

    return pathsOfFilesToRemove;
  }
}
