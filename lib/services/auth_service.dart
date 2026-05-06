import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';
import '../models/user_model.dart';
import 'dart:developer' as dev;

/// Service untuk mengelola autentikasi Firebase.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  /// Mendapatkan user yang sedang login
  User? get currentUser => _auth.currentUser;

  /// Stream perubahan status autentikasi
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Login dengan email dan password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('DEBUG: AuthService - Mencoba sign in: $email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      if (credential.user != null) {
        dev.log('Sign in successful: ${credential.user!.uid}', name: 'AuthService');
        await _userService.updateLastLogin(credential.user!.uid);
      }
      
      return credential;
    } catch (e) {
      dev.log('Sign in error: $e', name: 'AuthService', error: e);
      rethrow;
    }
  }

  /// Register akun baru dan simpan data user ke Firestore
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    UserCredential? credential;
    try {
      dev.log('Attempting registration for: $email', name: 'AuthService');
      
      // 1. Create user with FirebaseAuth
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        print('DEBUG: AuthService - Auth registrasi berhasil: ${user.uid}');
        
        // 2. Update displayName in Auth
        await user.updateDisplayName(name.trim());
        
        // 3. Save user profile to Firestore
        final now = DateTime.now();
        final userModel = UserModel(
          uid: user.uid,
          fullName: name.trim(),
          email: email.trim(),
          createdAt: now,
          updatedAt: now,
          lastLoginAt: now,
        );

        await _userService.createUserProfile(userModel);
        print('DEBUG: AuthService - Profil Firestore berhasil dibuat');
      }

      return credential;
    } catch (e) {
      dev.log('Registration error: $e', name: 'AuthService', error: e);
      // If we created the auth account but failed to create the firestore profile,
      // we might want to handle that. For now, we rethrow so the UI knows it failed.
      rethrow;
    }
  }

  /// Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Mendapatkan data user dari Firestore
  Future<UserModel?> getUserData(String uid) async {
    return await _userService.getUserProfile(uid);
  }
}
