import 'package:band_space/user/model/firebase_user_model.dart';
import 'package:band_space/user/model/user_model.dart';
import 'package:band_space/user/repository/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService(this._auth, this._userRepository);

  final FirebaseAuth _auth;
  final UserRepository _userRepository;

  bool get isUserAuthenticated => _auth.currentUser != null;

  UserModel? get user => isUserAuthenticated
      ? FirebaseUserModel.fromFirebaseUser(_auth.currentUser!)
      : null;

  Future<void> logIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    final user = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _userRepository.addUser(user.user?.uid ?? '', email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
