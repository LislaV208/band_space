// ignore_for_file: non_constant_identifier_names

import 'package:band_space/project/model/project_model.dart';
import 'package:band_space/user/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseProjectModel extends ProjectModel {
  const FirebaseProjectModel({
    required super.id,
    required super.name,
    required super.created_at,
    required super.created_by,
    required super.owners,
  });

  factory FirebaseProjectModel.fromDocument(
    DocumentSnapshot doc,
    UserModel creator,
    List<UserModel> owners,
  ) {
    final data = doc.data() as Map<String, dynamic>;

    return FirebaseProjectModel(
      id: doc.id,
      name: data['name'] ?? '',
      created_at: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : null,
      created_by: creator,
      owners: owners,
    );
  }
}
