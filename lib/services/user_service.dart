import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'dart:developer' as dev;

/// Service untuk mengelola data profil pengguna di Cloud Firestore.
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Membuat profil user baru di Firestore
  Future<void> createUserProfile(UserModel user) async {
    try {
      final docPath = 'users/${user.uid}';
      print('DEBUG: UserService - Menulis profil ke: $docPath');
      
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print('DEBUG: UserService - Error saat tulis profil: $e');
      rethrow;
    }
  }

  /// Mendapatkan profil user berdasarkan UID
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      dev.log('Error in getUserProfile: $e', name: 'UserService', error: e);
      rethrow;
    }
  }

  /// Mengupdate profil user
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      final updateData = {
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('users').doc(uid).update(updateData);
    } catch (e) {
      dev.log('Error in updateUserProfile: $e', name: 'UserService', error: e);
      rethrow;
    }
  }

  /// Mengupdate last login
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      dev.log('Error in updateLastLogin: $e', name: 'UserService', error: e);
    }
  }
}
