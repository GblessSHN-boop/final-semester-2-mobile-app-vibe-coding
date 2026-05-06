import 'package:cloud_firestore/cloud_firestore.dart';

/// Model data pengguna yang disimpan di Firestore.
class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String nim;
  final String programStudi;
  final String fakultas;
  final String angkatan;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLoginAt;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.nim = '',
    this.programStudi = '',
    this.fakultas = '',
    this.angkatan = '',
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLoginAt,
  });

  /// Konversi dari Firestore document snapshot
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? map['name'] ?? '', // Fallback to 'name' if exists
      email: map['email'] ?? '',
      nim: map['nim'] ?? '',
      programStudi: map['programStudi'] ?? '',
      fakultas: map['fakultas'] ?? '',
      angkatan: map['angkatan'] ?? '',
      photoUrl: map['photoUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Konversi ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'nim': nim,
      'programStudi': programStudi,
      'fakultas': fakultas,
      'angkatan': angkatan,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
    };
  }

  /// Membuat salinan dengan field yang diubah
  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? nim,
    String? programStudi,
    String? fakultas,
    String? angkatan,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      nim: nim ?? this.nim,
      programStudi: programStudi ?? this.programStudi,
      fakultas: fakultas ?? this.fakultas,
      angkatan: angkatan ?? this.angkatan,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
