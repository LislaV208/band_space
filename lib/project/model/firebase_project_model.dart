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
    return FirebaseProjectModel(
      id: doc.id,
      name: doc['name'] ?? '',
      created_at: DateTime.parse(doc['created_at']).toLocal(),
      created_by: creator,
      owners: owners,
    );
  }
}
