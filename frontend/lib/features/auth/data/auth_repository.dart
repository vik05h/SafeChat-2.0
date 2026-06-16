import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../domain/models/auth_models.dart';
import 'auth_api_service.dart';

class AuthRepository {
  final firebase.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final AuthApiService _apiService;

  AuthRepository({
    firebase.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    required AuthApiService apiService,
  })  : _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _apiService = apiService;

  Stream<firebase.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  firebase.User? get currentUser => _firebaseAuth.currentUser;

  Future<AuthState> checkAuthStatus() async {
    final user = currentUser;
    if (user == null) {
      return AuthState(user: null, needsOnboarding: true);
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      
      if (!doc.exists) {
        return AuthState(
          user: user,
          needsOnboarding: true,
        );
      }
      
      final data = doc.data()!;
      // Convert Timestamps to ISO strings for UserProfile.fromJson
      if (data['created_at'] is Timestamp) {
        data['created_at'] = (data['created_at'] as Timestamp).toDate().toIso8601String();
      }
      if (data['updated_at'] is Timestamp) {
        data['updated_at'] = (data['updated_at'] as Timestamp).toDate().toIso8601String();
      }

      final userProfile = UserProfile.fromJson(data);

      return AuthState(
        user: user,
        profile: userProfile,
        needsOnboarding: false,
      );
    } catch (e) {
      return AuthState(
        user: user,
        error: 'Firestore profile read failed: $e',
        needsOnboarding: true,
      );
    }
  }

  Future<AuthState> signInWithGoogle() async {
    try {
      // 1. Trigger the Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in flow
        return AuthState(error: 'Sign in aborted by user');
      }

      // 2. Obtain the auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create a new credential
      final firebase.OAuthCredential credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase
      final firebase.UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebase.User? user = userCredential.user;

      if (user == null) {
        return AuthState(error: 'Firebase sign in failed');
      }

      // 5. Call Firestore to verify onboard status and fetch profile
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        
        if (!doc.exists) {
          return AuthState(
            user: user,
            needsOnboarding: true,
          );
        }
        
        final data = doc.data()!;
        if (data['created_at'] is Timestamp) {
          data['created_at'] = (data['created_at'] as Timestamp).toDate().toIso8601String();
        }
        if (data['updated_at'] is Timestamp) {
          data['updated_at'] = (data['updated_at'] as Timestamp).toDate().toIso8601String();
        }

        final userProfile = UserProfile.fromJson(data);

        return AuthState(
          user: user,
          profile: userProfile,
          needsOnboarding: false,
        );
      } catch (e) {
        return AuthState(
          user: user,
          error: 'Firestore verification failed: $e',
          needsOnboarding: true, // Fail-safe
        );
      }
    } catch (e) {
      return AuthState(error: 'Sign in error: $e');
    }
  }

  Future<AuthState> onboard({
    required String username,
    required String displayName,
    required String phoneNumber,
    required String dob,
    String? bio,
  }) async {
    try {
      final request = OnboardRequest(
        username: username,
        displayName: displayName,
        phoneNumber: phoneNumber,
        dob: dob,
        bio: bio,
      );
      
      final response = await _apiService.onboard(request);
      final profileData = response.data['data']['profile'];
      final userProfile = UserProfile.fromJson(profileData);
      
      return AuthState(
        user: _firebaseAuth.currentUser,
        profile: userProfile,
        needsOnboarding: false,
      );
    } catch (e) {
      return AuthState(
        user: _firebaseAuth.currentUser,
        error: 'Onboarding failed: $e',
        needsOnboarding: true,
      );
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
