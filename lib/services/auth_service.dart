import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _userFromFirebaseUser(User? user) {
    if (user == null || user.email == null) return null;
    return UserModel(uid: user.uid, email: user.email!);
  }

  // Sign in
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    }
    catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign up
  Future<UserModel?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      print("Firebase user created: ${user?.uid}");
      print("Email from Firebase: ${user?.email}");

      UserModel? userModel = _userFromFirebaseUser(user);
      print("UserModel created: ${userModel?.uid}");

      return userModel;
    }
    catch (e) {
      print("Sign up error: ${e.toString()}");
      return null;
    }
  }
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}