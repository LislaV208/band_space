import 'package:band_space/comments/repository/comments_repository.dart';
import 'package:band_space/core/firestore/firestore_collection_names.dart';

class SongCommentsRepository extends CommentsRepository {
  final String songId;

  SongCommentsRepository({
    required this.songId,
    required super.userId,
    required super.db,
  });

  @override
  String get parentCollectionName => FirestoreCollectionNames.songs;

  @override
  String get parentId => songId;
}
