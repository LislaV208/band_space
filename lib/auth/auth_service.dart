import 'package:band_space/auth/model/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  bool get isUserAuthenticated => _auth.currentUser != null;

  UserData? get user =>
      isUserAuthenticated ? UserData(email: _auth.currentUser!.email!) : null;

  Future<void> logIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
