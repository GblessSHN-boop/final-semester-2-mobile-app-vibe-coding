import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'dart:developer' as dev;

/// Provider untuk mengelola state autentikasi.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _authService.currentUser != null;
  String? get userId => _authService.currentUser?.uid;

  /// Login dengan email dan password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      print('DEBUG: Memulai proses SignIn untuk $email');
      await _authService.signIn(email: email, password: password);
      await _loadUserData();
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _getAuthErrorMessage(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      dev.log('SignIn unexpected error: $e', name: 'AuthProvider', error: e);
      _error = 'Terjadi kesalahan sistem. Silakan coba lagi.';
      _setLoading(false);
      return false;
    }
  }

  /// Register akun baru
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      print('DEBUG: Memulai proses Registrasi untuk $email');
      // Log diagnostic info safely
      final options = Firebase.app().options;
      print('DEBUG: Firebase Project ID: ${options.projectId}');
      print('DEBUG: Firebase App ID: ${options.appId}');

      await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      
      print('DEBUG: Registrasi Berhasil!');
      await _loadUserData();
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      print('DEBUG: FirebaseAuthException - Code: ${e.code}, Message: ${e.message}');
      _error = _getAuthErrorMessage(e.code);
      _setLoading(false);
      return false;
    } catch (e) {
      print('DEBUG: Unexpected Error saat registrasi: $e');
      _error = 'Gagal menyimpan profil pengguna. Periksa koneksi internet Anda atau database Firestore.';
      _setLoading(false);
      return false;
    }
  }

  /// Logout
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> _loadUserData() async {
    final uid = _authService.currentUser?.uid;
    if (uid != null) {
      print('DEBUG: Memuat data user dari Firestore untuk UID: $uid');
      _user = await _authService.getUserData(uid);
      notifyListeners();
    }
  }

  /// Memeriksa dan memuat data user saat app dimulai
  Future<void> checkAuthState() async {
    if (_authService.currentUser != null) {
      await _loadUserData();
    }
  }

  /// Update nama user
  Future<bool> updateFullName(String newName) async {
    _setLoading(true);
    _error = null;
    try {
      final uid = _authService.currentUser?.uid;
      if (uid != null) {
        // We'll add a call to AuthService/UserService here if needed, 
        // but for now let's just implement the basic logic.
        final userService = UserService();
        await userService.updateUserProfile(uid, {'fullName': newName.trim()});
        _user = _user?.copyWith(fullName: newName.trim());
        notifyListeners();
      }
      _setLoading(false);
      return true;
    } catch (e) {
      dev.log('Update name error: $e', name: 'AuthProvider', error: e);
      _error = 'Gagal mengupdate nama.';
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Konversi kode error Firebase ke pesan bahasa Indonesia yang profesional
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Akun tidak ditemukan. Silakan periksa kembali email Anda atau daftar akun baru.';
      case 'wrong-password':
        return 'Password yang Anda masukkan salah. Silakan coba lagi.';
      case 'email-already-in-use':
        return 'Alamat email sudah terdaftar. Silakan gunakan email lain atau masuk dengan akun yang sudah ada.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter dengan kombinasi huruf dan angka.';
      case 'invalid-email':
        return 'Format email tidak valid. Pastikan penulisan email sudah benar.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan masuk yang gagal. Silakan coba lagi setelah beberapa saat.';
      case 'invalid-credential':
        return 'Email atau password tidak sesuai. Periksa kembali data login Anda.';
      case 'configuration-not-found':
      case 'internal-error':
        return 'Firebase Authentication belum terkonfigurasi dengan benar. Periksa Email/Password provider, package name, SHA-1/SHA-256, dan google-services.json.';
      case 'network-request-failed':
        return 'Gagal terhubung ke server. Periksa koneksi internet Anda.';
      default:
        return 'Terjadi kesalahan sistem (Kode: $code). Silakan hubungi administrator jika masalah berlanjut.';
    }
  }
}
