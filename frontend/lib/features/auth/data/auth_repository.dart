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
    required this._apiService,
  })  : _firebaseAuth = firebaseAuth ?? firebase.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  Stream<firebase.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  firebase.User? get currentUser => _firebaseAuth.currentUser;

  Future<AuthState> checkAuthStatus() async {
    final user = currentUser;
    if (user == null) {
      return AuthState(user: null, needsOnboarding: true);
    }

    try {
      // Call the backend so we get signed media URLs instead of raw GCS paths.
      final response = await _apiService.getMe();
      final data = response.data['data'] as Map<String, dynamic>;
      final needsOnboarding = data['needs_onboarding'] as bool? ?? true;

      if (needsOnboarding || data['profile'] == null) {
        return AuthState(user: user, needsOnboarding: true);
      }

      final userProfile = UserProfile.fromJson(
        data['profile'] as Map<String, dynamic>,
      );
      return AuthState(user: user, profile: userProfile, needsOnboarding: false);
    } catch (e) {
      return AuthState(
        user: user,
        error: 'Auth check failed: $e',
        needsOnboarding: true,
      );
    }
  }

  Future<AuthState> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }

      return AuthState(
        user: user,
        needsOnboarding: true,
      );
    } on firebase.FirebaseAuthException catch (e) {
      return AuthState(error: e.message ?? 'Sign up failed');
    } catch (e) {
      return AuthState(error: 'An unknown error occurred');
    }
  }

  Future<AuthState> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user == null) {
        return AuthState(error: 'User not found');
      }

      if (!user.emailVerified) {
        return AuthState(
          user: user,
          error: 'Please verify your email address.',
          needsOnboarding: true,
        );
      }

      // Check if user is onboarded
      return await checkAuthStatus();
    } on firebase.FirebaseAuthException catch (e) {
      return AuthState(error: e.message ?? 'Sign in failed');
    } catch (e) {
      return AuthState(error: 'An unknown error occurred');
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

      // 5. Verify onboard status and fetch profile (with signed URLs) via API.
      return await checkAuthStatus();
    } catch (e) {
      return AuthState(error: 'Sign in error: $e');
    }
  }

  Future<AuthState> onboard({
    required String username,
    required String displayName,
    String? phoneNumber,
    required String dob,
    String? bio,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found.');
      }

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
        user: user,
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

  Future<AuthState> updateProfile({
    String? displayName,
    String? username,
    String? bio,
    String? photoUrl,
    String? backgroundUrl,
    ImageTransform? avatarTransform,
    ImageTransform? coverTransform,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No authenticated user found.');

      final request = UpdateProfileRequest(
        displayName: displayName,
        username: username,
        bio: bio,
        photoUrl: photoUrl,
        backgroundUrl: backgroundUrl,
        avatarTransform: avatarTransform,
        coverTransform: coverTransform,
      );

      final response = await _apiService.updateProfile(request);
      final profileData = response.data['data']['profile'];
      
      final userProfile = UserProfile.fromJson(profileData);
      
      return AuthState(
        user: user,
        profile: userProfile,
        needsOnboarding: false,
      );
    } catch (e) {
      return AuthState(
        user: _firebaseAuth.currentUser,
        error: 'Profile update failed: $e',
        needsOnboarding: false,
      );
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
