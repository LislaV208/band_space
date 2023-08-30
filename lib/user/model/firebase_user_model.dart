import 'package:band_space/user/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseUserModel extends UserModel {
  const FirebaseUserModel({required super.id, required super.email});

  factory FirebaseUserModel.fromDocument(DocumentSnapshot doc) {
    return FirebaseUserModel(
      id: doc.id,
      email: doc['email'] ?? '',
    );
  }
}
