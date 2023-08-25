import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserData extends Equatable {
  const UserData({
    required this.id,
    required this.email,
  });

  final String id;
  final String email;

  @override
  List<Object> get props => [id, email];

  factory UserData.fromFirebaseUser(User user) {
    return UserData(id: user.uid, email: user.email ?? '');
  }
}
