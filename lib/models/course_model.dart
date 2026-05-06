import 'package:cloud_firestore/cloud_firestore.dart';

/// Model data mata kuliah yang disimpan di Firestore.
class CourseModel {
  final String id;
  final String userId;
  final String semesterId;
  final String courseName;
  final int sks;
  final String gradeLetter;
  final double gradePoint;
  final double qualityPoint;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseModel({
    required this.id,
    required this.userId,
    required this.semesterId,
    required this.courseName,
    required this.sks,
    required this.gradeLetter,
    required this.gradePoint,
    required this.qualityPoint,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Konversi dari Firestore document snapshot
  factory CourseModel.fromMap(Map<String, dynamic> map, String id) {
    return CourseModel(
      id: id,
      userId: map['userId'] ?? '',
      semesterId: map['semesterId'] ?? '',
      courseName: map['courseName'] ?? '',
      sks: (map['sks'] ?? 0) is int ? map['sks'] : (map['sks'] as num).toInt(),
      gradeLetter: map['gradeLetter'] ?? '',
      gradePoint: (map['gradePoint'] ?? 0.0).toDouble(),
      qualityPoint: (map['qualityPoint'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Konversi ke Map untuk disimpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'semesterId': semesterId,
      'courseName': courseName,
      'sks': sks,
      'gradeLetter': gradeLetter,
      'gradePoint': gradePoint,
      'qualityPoint': qualityPoint,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Membuat salinan dengan field yang diubah
  CourseModel copyWith({
    String? id,
    String? userId,
    String? semesterId,
    String? courseName,
    int? sks,
    String? gradeLetter,
    double? gradePoint,
    double? qualityPoint,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      semesterId: semesterId ?? this.semesterId,
      courseName: courseName ?? this.courseName,
      sks: sks ?? this.sks,
      gradeLetter: gradeLetter ?? this.gradeLetter,
      gradePoint: gradePoint ?? this.gradePoint,
      qualityPoint: qualityPoint ?? this.qualityPoint,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
