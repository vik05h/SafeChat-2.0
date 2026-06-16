import 'package:firebase_auth/firebase_auth.dart' as firebase;
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

      // 5. Call the backend to verify onboard status and fetch profile
      // The Dio interceptor will automatically attach the Firebase token
      try {
        final response = await _apiService.getMe();
        final data = response.data['data'];
        
        UserProfile? userProfile;
        if (data['profile'] != null) {
          userProfile = UserProfile.fromJson(data['profile']);
        }

        return AuthState(
          user: user,
          profile: userProfile,
          needsOnboarding: data['needs_onboarding'] ?? true,
        );
      } catch (e) {
        // If the backend call fails, we still have the firebase user, but we might want to error out
        // or treat them as needing onboarding if we can't confirm.
        return AuthState(
          user: user,
          error: 'Backend verification failed: $e',
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
