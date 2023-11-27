// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:band_space/user/model/personal_data.dart';
import 'package:band_space/user/model/user_model.dart';

class FirebaseUserModel extends UserModel {
  const FirebaseUserModel({
    required super.id,
    required super.email,
    required super.personal_data,
  });

  factory FirebaseUserModel.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final personalDataMap = data?['personal_data'] as Map<String, dynamic>?;

    return FirebaseUserModel(
      id: doc.id,
      email: data?['email'] ?? '',
      personal_data: personalDataMap != null ? PersonalData.fromMap(personalDataMap) : null,
    );
  }
}
