import 'package:band_space/comments/repository/comments_repository.dart';

class SongCommentsRepository extends CommentsRepository {
  final String songId;

  SongCommentsRepository({
    required this.songId,
    required super.userId,
    required super.db,
  });

  @override
  String get parentCollectionName => 'songs';

  @override
  String get parentId => songId;
}
