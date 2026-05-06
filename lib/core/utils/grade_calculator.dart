import '../../models/course_model.dart';

/// Utility class untuk perhitungan IPS dan IPK.
class GradeCalculator {
  GradeCalculator._();

  /// Menghitung IPS (Indeks Prestasi Semester)
  /// IPS = total nilai mutu / total SKS dalam satu semester
  static double calculateIPS(List<CourseModel> courses) {
    if (courses.isEmpty) return 0.0;

    double totalQualityPoints = 0;
    int totalSKS = 0;

    for (final course in courses) {
      totalQualityPoints += course.qualityPoint;
      totalSKS += course.sks;
    }

    if (totalSKS == 0) return 0.0;
    return totalQualityPoints / totalSKS;
  }

  /// Menghitung IPK (Indeks Prestasi Kumulatif)
  /// IPK = total seluruh nilai mutu / total seluruh SKS
  static double calculateIPK(List<CourseModel> allCourses) {
    if (allCourses.isEmpty) return 0.0;

    double totalQualityPoints = 0;
    int totalSKS = 0;

    for (final course in allCourses) {
      totalQualityPoints += course.qualityPoint;
      totalSKS += course.sks;
    }

    if (totalSKS == 0) return 0.0;
    return totalQualityPoints / totalSKS;
  }

  /// Menghitung total SKS dari daftar mata kuliah
  static int calculateTotalSKS(List<CourseModel> courses) {
    int total = 0;
    for (final course in courses) {
      total += course.sks;
    }
    return total;
  }

  /// Menghitung total nilai mutu dari daftar mata kuliah
  static double calculateTotalQualityPoints(List<CourseModel> courses) {
    double total = 0;
    for (final course in courses) {
      total += course.qualityPoint;
    }
    return total;
  }

  /// Simulasi target IPK.
  /// Menghitung rata-rata grade point yang dibutuhkan pada semester berikutnya
  /// untuk mencapai target IPK tertentu.
  ///
  /// Rumus:
  /// targetIPK = (currentTotalQP + neededQP) / (currentTotalSKS + plannedSKS)
  /// neededQP = targetIPK * (currentTotalSKS + plannedSKS) - currentTotalQP
  /// neededAvgGP = neededQP / plannedSKS
  static double simulateTargetIPK({
    required double currentTotalQualityPoints,
    required int currentTotalSKS,
    required double targetIPK,
    required int plannedSKS,
  }) {
    if (plannedSKS <= 0) return 0.0;

    final totalSKSAfter = currentTotalSKS + plannedSKS;
    final neededTotalQP = targetIPK * totalSKSAfter;
    final neededQP = neededTotalQP - currentTotalQualityPoints;
    final neededAvgGP = neededQP / plannedSKS;

    return neededAvgGP;
  }

  /// Mendapatkan deskripsi predikat berdasarkan IPK
  static String getIPKPredikat(double ipk) {
    if (ipk >= 3.51) return 'Cum Laude';
    if (ipk >= 2.76) return 'Sangat Memuaskan';
    if (ipk >= 2.00) return 'Memuaskan';
    return 'Kurang Memuaskan';
  }

  /// Format angka IPS/IPK ke 2 desimal
  static String formatGPA(double value) {
    return value.toStringAsFixed(2);
  }
}
