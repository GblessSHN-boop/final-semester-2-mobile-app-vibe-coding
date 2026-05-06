import 'package:cloud_firestore/cloud_firestore.dart';

/// Model data semester yang disimpan di Firestore.
class SemesterModel {
  final String id;
  final String userId;
  final String semesterName;
  final DateTime createdAt;

  SemesterModel({
    required this.id,
    required this.userId,
    required this.semesterName,
    required this.createdAt,
  });

  /// Konversi dari Firestore document snapshot
  factory SemesterModel.fromMap(Map<String, dynamic> map, String id) {
    return SemesterModel(
      id: id,
      userId: map['userId'] ?? '',
      semesterName: map['semesterName'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Konversi ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'semesterName': semesterName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Membuat salinan dengan field yang diubah
  SemesterModel copyWith({
    String? id,
    String? userId,
    String? semesterName,
    DateTime? createdAt,
  }) {
    return SemesterModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      semesterName: semesterName ?? this.semesterName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
