import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/firestore_service.dart';
import '../core/constants/grade_data.dart';

/// Provider untuk mengelola state mata kuliah dalam satu semester.
class CourseProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CourseModel> _courses = [];
  bool _isLoading = false;
  String? _error;

  List<CourseModel> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Memuat daftar mata kuliah untuk semester tertentu
  Future<void> loadCourses(String userId, String semesterId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await _firestoreService.getCoursesBySemesterFuture(
          userId, semesterId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Gagal memuat mata kuliah.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menambahkan mata kuliah baru
  Future<bool> addCourse({
    required String userId,
    required String semesterId,
    required String courseName,
    required int sks,
    required String gradeLetter,
  }) async {
    _error = null;
    try {
      final gradePoint = GradeData.getGradePoint(gradeLetter);
      final qualityPoint = GradeData.calculateQualityPoint(sks, gradeLetter);
      final now = DateTime.now();

      final course = CourseModel(
        id: '',
        userId: userId,
        semesterId: semesterId,
        courseName: courseName.trim(),
        sks: sks,
        gradeLetter: gradeLetter,
        gradePoint: gradePoint,
        qualityPoint: qualityPoint,
        createdAt: now,
        updatedAt: now,
      );

      await _firestoreService.addCourse(course);
      await loadCourses(userId, semesterId);
      return true;
    } catch (e) {
      _error = 'Gagal menambahkan mata kuliah.';
      notifyListeners();
      return false;
    }
  }

  /// Mengupdate mata kuliah
  Future<bool> updateCourse({
    required String courseId,
    required String userId,
    required String semesterId,
    required String courseName,
    required int sks,
    required String gradeLetter,
  }) async {
    _error = null;
    try {
      final gradePoint = GradeData.getGradePoint(gradeLetter);
      final qualityPoint = GradeData.calculateQualityPoint(sks, gradeLetter);

      final course = CourseModel(
        id: courseId,
        userId: userId,
        semesterId: semesterId,
        courseName: courseName.trim(),
        sks: sks,
        gradeLetter: gradeLetter,
        gradePoint: gradePoint,
        qualityPoint: qualityPoint,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.updateCourse(courseId, course);
      await loadCourses(userId, semesterId);
      return true;
    } catch (e) {
      _error = 'Gagal mengupdate mata kuliah.';
      notifyListeners();
      return false;
    }
  }

  /// Menghapus mata kuliah
  Future<bool> deleteCourse(
      String courseId, String userId, String semesterId) async {
    _error = null;
    try {
      await _firestoreService.deleteCourse(courseId);
      await loadCourses(userId, semesterId);
      return true;
    } catch (e) {
      _error = 'Gagal menghapus mata kuliah.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
