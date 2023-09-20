import 'package:band_space/comments/repository/comments_repository.dart';

class MarkerCommentsRepository extends CommentsRepository {
  final String markerId;

  const MarkerCommentsRepository({
    required this.markerId,
    required super.userId,
    required super.db,
  });

  @override
  String get parentCollectionName => 'markers';

  @override
  String get parentId => markerId;
}
