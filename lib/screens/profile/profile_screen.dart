import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/grade_calculator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/semester_provider.dart';
import '../auth/login_screen.dart';
import 'about_screen.dart';

/// Halaman Profil Pengguna.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final sem = Provider.of<SemesterProvider>(context, listen: false);
    if (auth.userId != null) await sem.loadAllData(auth.userId!);
  }

  void _showEditNameDialog() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final controller = TextEditingController(text: auth.user?.fullName ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Nama', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Nama lengkap', hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent, width: 2)),
          ),
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                final success = await auth.updateFullName(controller.text.trim());
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('Nama berhasil diupdate'), backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Simpan', style: GoogleFonts.poppins(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Apakah Anda yakin ingin keluar?', style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Logout', style: GoogleFonts.poppins(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer2<AuthProvider, SemesterProvider>(
        builder: (context, auth, sem, _) {
          return SingleChildScrollView(
            child: Column(children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20, left: 20, right: 20, bottom: 28),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
                ),
                child: Column(children: [
                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white.withValues(alpha: 0.5), width: 3)),
                    child: CircleAvatar(
                      radius: 42, backgroundColor: AppColors.white.withValues(alpha: 0.2),
                      child: Text(
                        (auth.user?.fullName ?? 'U').substring(0, 1).toUpperCase(),
                        style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(auth.user?.fullName ?? 'User',
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white)),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _showEditNameDialog,
                      child: Container(padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                        child: const Icon(Icons.edit_rounded, color: AppColors.white, size: 16)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(auth.user?.email ?? '', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.white.withValues(alpha: 0.7))),
                ]),
              ),
              // Stats
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Statistik Akademik', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _buildStatItem('Semester', '${sem.semesterCount}', Icons.calendar_month_rounded, AppColors.accent)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatItem('Mata Kuliah', '${sem.courseCount}', Icons.book_rounded, AppColors.success)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _buildStatItem('Total SKS', '${sem.totalSKS}', Icons.credit_card_rounded, AppColors.warning)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatItem('IPK', GradeCalculator.formatGPA(sem.ipk), Icons.school_rounded, AppColors.primaryDark)),
                  ]),
                  const SizedBox(height: 24),
                  // Menu Items
                  _buildMenuItem(Icons.info_rounded, 'Tentang Aplikasi', 'Informasi aplikasi & teknologi',
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()))),
                  const SizedBox(height: 12),
                  _buildMenuItem(Icons.logout_rounded, 'Logout', 'Keluar dari akun', _handleLogout, isDestructive: true),
                ]),
              ),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          Text(title, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap, {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))]),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isDestructive ? AppColors.error : AppColors.accent).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: isDestructive ? AppColors.error : AppColors.accent, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600,
              color: isDestructive ? AppColors.error : AppColors.textPrimary)),
            Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
          ])),
          Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isDestructive ? AppColors.error : AppColors.greyMedium),
        ]),
      ),
    );
  }
}
