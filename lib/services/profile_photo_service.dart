import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePhotoService {
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> pickAndReplaceProfilePhoto() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    final pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 35,
      maxWidth: 220,
      maxHeight: 220,
    );

    if (pickedImage == null) {
      return null;
    }

    final imageBytes = await pickedImage.readAsBytes();

    if (imageBytes.length > 350 * 1024) {
      throw Exception(
        'Ukuran foto masih terlalu besar. Pilih foto yang lebih kecil.',
      );
    }

    final photoBase64 = base64Encode(imageBytes);
    final mimeType = pickedImage.mimeType ?? 'image/jpeg';

    final userRef = _firestore.collection('users').doc(user.uid);

    await userRef.set({
      'photoBase64': FieldValue.delete(),
      'photoMimeType': FieldValue.delete(),
      'photoUpdatedAt': FieldValue.delete(),
    }, SetOptions(merge: true));

    await userRef.set({
      'photoBase64': photoBase64,
      'photoMimeType': mimeType,
      'photoUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return photoBase64;
  }

  Future<void> deleteProfilePhoto() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    await _firestore.collection('users').doc(user.uid).set({
      'photoBase64': FieldValue.delete(),
      'photoMimeType': FieldValue.delete(),
      'photoUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String?> getProfilePhotoBase64() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    return userDoc.data()?['photoBase64'];
  }
}
