import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final Dio _dio;

  AuthService(this._firebaseAuth, this._dio);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password, String username) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Call backend to onboard user
      if (credential.user != null) {
        await _dio.post('/auth/onboard', data: {
          'username': username,
          'display_name': username,
          'bio': ''
        });
      }
      
      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      // Cleanup Firebase user if backend onboarding fails
      await _firebaseAuth.currentUser?.delete();
      throw Exception('Failed to create profile: $e');
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
  
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }
  
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }
}
