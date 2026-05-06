import 'package:flutter/material.dart';

/// Palet warna utama aplikasi Kalkulator IPK & IPS.
/// Menggunakan kombinasi biru tua, putih, abu-abu muda, dan aksen biru cerah.
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryDark = Color(0xFF1A237E);
  static const Color primary = Color(0xFF283593);
  static const Color primaryLight = Color(0xFF3949AB);

  // Accent Colors
  static const Color accent = Color(0xFF2196F3);
  static const Color accentLight = Color(0xFF42A5F5);
  static const Color accentSoft = Color(0xFF90CAF9);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color greyLight = Color(0xFFF0F0F0);
  static const Color greyMedium = Color(0xFFBDBDBD);
  static const Color greyDark = Color(0xFF757575);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
  );
}
