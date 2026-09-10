import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseAuth get auth => _auth;

  /// REGISTER
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// LOGIN
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// SEND EMAIL VERIFICATION
  Future<void> sendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// RELOAD CURRENT USER
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// EMAIL VERIFIED?
  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// CURRENT USER
  User? get currentUser {
    return _auth.currentUser;
  }

  /// CURRENT USER EMAIL
  String? get currentUserEmail {
    return _auth.currentUser?.email;
  }

  /// CHECK CURRENT USER VERIFICATION
  Future<bool> checkCurrentUserVerified() async {
    await _auth.currentUser?.reload();

    return _auth.currentUser?.emailVerified ?? false;
  }

  /// SIGN OUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// RESET PASSWORD
  Future<void> forgotPassword(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email,
    );
  }

  /// RESET PIN
  Future<void> forgotPin(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email,
    );
  }
}

final authService = AuthService();