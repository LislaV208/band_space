import 'package:band_space/comments/model/comment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class CommentsRepository {
  final String userId;
  final FirebaseFirestore db;

  const CommentsRepository({
    required this.userId,
    required this.db,
  });

  String get parentCollectionName;
  String get parentId;

  DocumentReference get _parentRef => db.collection(parentCollectionName).doc(parentId);

  Future<void> addComment(String content) async {
    final userRef = db.collection('users').doc(userId);

    final commentRef = db.collection('comments').doc();
    await commentRef.set({
      'parent': _parentRef,
      'created_at': Timestamp.now(),
      'created_by': userRef,
      'content': content,
    });
  }

  Stream<List<Comment>> getComments() {
    return db
        .collection('comments')
        .where('parent', isEqualTo: _parentRef)
        .orderBy('created_at')
        .snapshots()
        .asyncMap((event) async {
      return await Future.wait(event.docs.map((doc) async {
        final data = doc.data();
        final userRef = data['created_by'] as DocumentReference<Map<String, dynamic>>;

        final userDoc = await userRef.get();
        final userData = userDoc.data();

        return Comment(
          id: doc.id,
          created_by: userData?['email'] ?? '',
          content: data['content'] ?? '',
        );
      }));
    });
  }

  Future<void> deleteComment(String id) async {
    await db.collection('comments').doc(id).delete();
  }
}
