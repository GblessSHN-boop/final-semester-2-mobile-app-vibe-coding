/// Mapping nilai huruf ke bobot nilai (grade point).
class GradeData {
  GradeData._();

  /// Map nilai huruf → bobot
  static const Map<String, double> gradePoints = {
    'A': 4.00,
    'A-': 3.75,
    'B+': 3.50,
    'B': 3.00,
    'B-': 2.75,
    'C+': 2.50,
    'C': 2.00,
    'D': 1.00,
    'E': 0.00,
  };

  /// Daftar nilai huruf untuk dropdown
  static const List<String> gradeLetters = [
    'A',
    'A-',
    'B+',
    'B',
    'B-',
    'C+',
    'C',
    'D',
    'E',
  ];

  /// Mendapatkan bobot dari nilai huruf
  static double getGradePoint(String gradeLetter) {
    return gradePoints[gradeLetter] ?? 0.0;
  }

  /// Menghitung nilai mutu (quality point) = SKS × bobot
  static double calculateQualityPoint(int sks, String gradeLetter) {
    return sks * getGradePoint(gradeLetter);
  }

  /// Mendapatkan warna badge berdasarkan nilai huruf
  static String getGradeCategory(String gradeLetter) {
    switch (gradeLetter) {
      case 'A':
      case 'A-':
        return 'excellent';
      case 'B+':
      case 'B':
        return 'good';
      case 'B-':
      case 'C+':
        return 'average';
      case 'C':
      case 'D':
        return 'below_average';
      case 'E':
        return 'fail';
      default:
        return 'unknown';
    }
  }
}
