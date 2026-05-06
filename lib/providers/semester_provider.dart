import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/semester_model.dart';
import '../models/course_model.dart';
import '../services/firestore_service.dart';
import '../core/utils/grade_calculator.dart';

/// Provider untuk mengelola state daftar semester.
class SemesterProvider extends ChangeNotifier {
  void _safeNotifyListeners() {
    final schedulerPhase = SchedulerBinding.instance.schedulerPhase;

    if (schedulerPhase == SchedulerPhase.idle ||
        schedulerPhase == SchedulerPhase.postFrameCallbacks) {
      notifyListeners();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  final FirestoreService _firestoreService = FirestoreService();

  List<SemesterModel> _semesters = [];
  Map<String, List<CourseModel>> _semesterCourses = {};
  List<CourseModel> _allCourses = [];
  bool _isLoading = false;
  String? _error;

  List<SemesterModel> get semesters => _semesters;
  Map<String, List<CourseModel>> get semesterCourses => _semesterCourses;
  List<CourseModel> get allCourses => _allCourses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// IPK kumulatif dihitung dari semua mata kuliah
  double get ipk => GradeCalculator.calculateIPK(_allCourses);

  /// Total SKS kumulatif
  int get totalSKS => GradeCalculator.calculateTotalSKS(_allCourses);

  /// Total nilai mutu kumulatif
  double get totalQualityPoints =>
      GradeCalculator.calculateTotalQualityPoints(_allCourses);

  /// Jumlah semester
  int get semesterCount => _semesters.length;

  /// Jumlah mata kuliah
  int get courseCount => _allCourses.length;

  /// Mendapatkan IPS untuk semester tertentu
  double getIPS(String semesterId) {
    final courses = _semesterCourses[semesterId] ?? [];
    return GradeCalculator.calculateIPS(courses);
  }

  /// Mendapatkan total SKS semester tertentu
  int getSemesterSKS(String semesterId) {
    final courses = _semesterCourses[semesterId] ?? [];
    return GradeCalculator.calculateTotalSKS(courses);
  }

  /// Mendapatkan jumlah MK semester tertentu
  int getSemesterCourseCount(String semesterId) {
    return (_semesterCourses[semesterId] ?? []).length;
  }

  /// Memuat semua data semester dan courses dari Firestore
  Future<void> loadAllData(String userId) async {
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      // Muat semester
      _semesters = await _firestoreService.getSemestersFuture(userId);

      debugPrint('UID aktif: $userId');
      debugPrint('Jumlah semester terbaca: ${_semesters.length}');
      debugPrint(
        'Data semester: ${_semesters.map((e) => e.semesterName).join(', ')}',
      );

      // Muat semua courses
      _allCourses = await _firestoreService.getAllCoursesFuture(userId);

      // Kelompokkan coursess per semester
      _semesterCourses = {};
      for (final course in _allCourses) {
        if (!_semesterCourses.containsKey(course.semesterId)) {
          _semesterCourses[course.semesterId] = [];
        }
        _semesterCourses[course.semesterId]!.add(course);
      }

      _isLoading = false;
      _safeNotifyListeners();
    } catch (e) {
      _error = 'Gagal memuat data: ${e.toString()}';
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  /// Menambahkan semester baru
  Future<bool> addSemester(String userId, String semesterName) async {
    _error = null;
    try {
      final semester = SemesterModel(
        id: '',
        userId: userId,
        semesterName: semesterName.trim(),
        createdAt: DateTime.now(),
      );
      await _firestoreService.addSemester(semester);
      await loadAllData(userId);
      return true;
    } catch (e) {
      _error = 'Gagal menambahkan semester.';
      _safeNotifyListeners();
      return false;
    }
  }

  /// Mengupdate nama semester
  Future<bool> updateSemester(
    String userId,
    String semesterId,
    String newName,
  ) async {
    _error = null;
    try {
      await _firestoreService.updateSemester(semesterId, newName);
      await loadAllData(userId);
      return true;
    } catch (e) {
      _error = 'Gagal mengupdate semester.';
      _safeNotifyListeners();
      return false;
    }
  }

  /// Menghapus semester beserta semua mata kuliahnya
  Future<bool> deleteSemester(String userId, String semesterId) async {
    _error = null;
    try {
      await _firestoreService.deleteSemester(semesterId, userId);
      await loadAllData(userId);
      return true;
    } catch (e) {
      _error = 'Gagal menghapus semester.';
      _safeNotifyListeners();
      return false;
    }
  }

  /// Mendapatkan data IPS per semester (untuk grafik statistik)
  List<Map<String, dynamic>> getIPSPerSemester() {
    final result = <Map<String, dynamic>>[];
    for (final semester in _semesters) {
      final courses = _semesterCourses[semester.id] ?? [];
      final ips = GradeCalculator.calculateIPS(courses);
      result.add({
        'semesterName': semester.semesterName,
        'ips': ips,
        'semesterId': semester.id,
      });
    }
    return result;
  }

  /// Mendapatkan semester dengan IPS tertinggi
  Map<String, dynamic>? getHighestIPSSemester() {
    final ipsData = getIPSPerSemester();
    if (ipsData.isEmpty) return null;
    // Filter hanya semester yang punya MK
    final withCourses = ipsData.where((d) => (d['ips'] as double) > 0).toList();
    if (withCourses.isEmpty) return null;
    withCourses.sort(
      (a, b) => (b['ips'] as double).compareTo(a['ips'] as double),
    );
    return withCourses.first;
  }

  /// Mendapatkan semester dengan IPS terendah
  Map<String, dynamic>? getLowestIPSSemester() {
    final ipsData = getIPSPerSemester();
    if (ipsData.isEmpty) return null;
    final withCourses = ipsData.where((d) => (d['ips'] as double) > 0).toList();
    if (withCourses.isEmpty) return null;
    withCourses.sort(
      (a, b) => (a['ips'] as double).compareTo(b['ips'] as double),
    );
    return withCourses.first;
  }

  void clearError() {
    _error = null;
    _safeNotifyListeners();
  }
}
