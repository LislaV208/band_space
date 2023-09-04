import 'package:band_space/user/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUserModel extends UserModel {
  const FirebaseUserModel({required super.id, required super.email});

  factory FirebaseUserModel.fromDocument(DocumentSnapshot doc) {
    return FirebaseUserModel(
      id: doc.id,
      email: doc['email'] ?? '',
    );
  }

  factory FirebaseUserModel.fromFirebaseUser(User user) {
    return FirebaseUserModel(id: user.uid, email: user.email ?? '');
  }
}
