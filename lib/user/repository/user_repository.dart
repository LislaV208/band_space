import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:band_space/core/firestore/firestore_collection_names.dart';
import 'package:band_space/user/model/firebase_user_model.dart';
import 'package:band_space/user/model/personal_data.dart';
import 'package:band_space/user/model/user_model.dart';

class UserRepository {
  UserRepository(this._db);

  final FirebaseFirestore _db;

  Future<void> addUser(String id, String email) async {
    await _db.collection('users').doc(id).set({'email': email});
  }

  Future<UserModel> getUser(String id) async {
    final userDoc = await _db.collection(FirestoreCollectionNames.users).doc(id).get();

    return FirebaseUserModel.fromDocument(userDoc);
  }

  Future<UserModel> updateUserPersonalData(String userId, PersonalData personalData) async {
    final userRef = _db.collection(FirestoreCollectionNames.users).doc(userId);
    await userRef.update({
      'personal_data': personalData.toMap(),
    });

    final userDoc = await userRef.get();

    return FirebaseUserModel.fromDocument(userDoc);
  }
}
