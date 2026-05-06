import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

/// Halaman About App - Informasi tentang aplikasi.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Tentang Aplikasi',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.white)),
        backgroundColor: AppColors.primary, elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.school_rounded, size: 56, color: AppColors.white),
            ),
            const SizedBox(height: 20),
            Text('Kalkulator IPK & IPS',
                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('Versi 1.0.0', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 28),
            _buildSection('📱 Tentang',
                'Kalkulator IPK & IPS adalah aplikasi mobile yang dirancang untuk membantu mahasiswa menghitung Indeks Prestasi Semester (IPS) dan Indeks Prestasi Kumulatif (IPK) secara otomatis dan akurat.'),
            _buildSection('🎯 Tujuan',
                'Mempermudah mahasiswa dalam memantau perkembangan akademik, mencatat nilai setiap semester, dan merencanakan target prestasi dengan fitur simulasi IPK.'),
            _buildSection('🛠️ Teknologi',
                '• Flutter - Framework UI modern\n• Firebase Authentication - Autentikasi pengguna\n• Cloud Firestore - Database realtime\n• Provider - State management\n• fl_chart - Visualisasi grafik'),
            _buildSection('✨ Fitur Utama',
                '• Perhitungan IPS & IPK otomatis\n• Pencatatan nilai per semester\n• Grafik perkembangan akademik\n• Simulasi target IPK\n• Penyimpanan data aman di cloud\n• UI modern dan responsif'),
            _buildSection('🎓 Manfaat',
                '• Membantu mahasiswa memantau prestasi akademik\n• Merencanakan target nilai semester depan\n• Menyimpan riwayat nilai secara digital\n• Memudahkan evaluasi performa akademik\n• Praktis digunakan di mana saja'),
            const SizedBox(height: 20),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.infoLight, borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                Text('Dibuat dengan ❤️',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary)),
                Text('Proyek Portofolio Mahasiswa Informatika',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(content, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
      ]),
    );
  }
}
