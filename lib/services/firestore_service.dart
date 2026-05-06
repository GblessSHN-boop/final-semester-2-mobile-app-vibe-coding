import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/semester_model.dart';
import '../models/course_model.dart';

/// Service untuk operasi CRUD di Cloud Firestore.
/// Semua query difilter berdasarkan userId untuk keamanan data.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== SEMESTER ====================

  /// Mendapatkan stream daftar semester milik user
  Stream<List<SemesterModel>> getSemesters(String userId) {
    return _firestore
        .collection('semesters')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final semesters = snapshot.docs
              .map((doc) => SemesterModel.fromMap(doc.data(), doc.id))
              .toList();

          semesters.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          return semesters;
        });
  }

  /// Mendapatkan daftar semester (Future, bukan Stream)
  Future<List<SemesterModel>> getSemestersFuture(String userId) async {
    final snapshot = await _firestore
        .collection('semesters')
        .where('userId', isEqualTo: userId)
        .get();

    final semesters = snapshot.docs
        .map((doc) => SemesterModel.fromMap(doc.data(), doc.id))
        .toList();

    semesters.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return semesters;
  }

  /// Menambahkan semester baru
  Future<String> addSemester(SemesterModel semester) async {
    final docRef = await _firestore
        .collection('semesters')
        .add(semester.toMap());
    return docRef.id;
  }

  /// Mengupdate nama semester
  Future<void> updateSemester(String semesterId, String newName) async {
    await _firestore.collection('semesters').doc(semesterId).update({
      'semesterName': newName.trim(),
    });
  }

  /// Menghapus semester beserta semua mata kuliah terkait (cascade delete)
  Future<void> deleteSemester(String semesterId, String userId) async {
    // Hapus semua courses yang terkait dengan semester ini
    final coursesSnapshot = await _firestore
        .collection('courses')
        .where('userId', isEqualTo: userId)
        .where('semesterId', isEqualTo: semesterId)
        .get();

    final batch = _firestore.batch();

    for (final doc in coursesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Hapus semester
    batch.delete(_firestore.collection('semesters').doc(semesterId));

    await batch.commit();
  }

  // ==================== COURSES ====================

  /// Mendapatkan stream daftar mata kuliah dalam satu semester
  Stream<List<CourseModel>> getCourses(String userId, String semesterId) {
    return _firestore
        .collection('courses')
        .where('userId', isEqualTo: userId)
        .where('semesterId', isEqualTo: semesterId)
        .snapshots()
        .map((snapshot) {
          final courses = snapshot.docs
              .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
              .toList();

          courses.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          return courses;
        });
  }

  /// Mendapatkan semua mata kuliah milik user (untuk hitung IPK)
  Stream<List<CourseModel>> getAllCourses(String userId) {
    return _firestore
        .collection('courses')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Mendapatkan semua mata kuliah milik user (Future)
  Future<List<CourseModel>> getAllCoursesFuture(String userId) async {
    final snapshot = await _firestore
        .collection('courses')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Mendapatkan courses per semester (Future)
  Future<List<CourseModel>> getCoursesBySemesterFuture(
    String userId,
    String semesterId,
  ) async {
    final snapshot = await _firestore
        .collection('courses')
        .where('userId', isEqualTo: userId)
        .where('semesterId', isEqualTo: semesterId)
        .get();

    return snapshot.docs
        .map((doc) => CourseModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// Menambahkan mata kuliah baru
  Future<String> addCourse(CourseModel course) async {
    final docRef = await _firestore.collection('courses').add(course.toMap());
    return docRef.id;
  }

  /// Mengupdate mata kuliah
  Future<void> updateCourse(String courseId, CourseModel course) async {
    await _firestore.collection('courses').doc(courseId).update({
      'courseName': course.courseName,
      'sks': course.sks,
      'gradeLetter': course.gradeLetter,
      'gradePoint': course.gradePoint,
      'qualityPoint': course.qualityPoint,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Menghapus mata kuliah
  Future<void> deleteCourse(String courseId) async {
    await _firestore.collection('courses').doc(courseId).delete();
  }
}
