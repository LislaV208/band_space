import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  UserRepository(this._db);

  final FirebaseFirestore _db;

  Future<void> addUser(String id, String email) async {
    await _db.collection('users').doc(id).set({'email': email});
  }
}
