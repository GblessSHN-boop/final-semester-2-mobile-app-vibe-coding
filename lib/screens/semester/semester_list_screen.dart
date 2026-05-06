import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/semester_provider.dart';
import '../../widgets/semester_card.dart';
import '../../widgets/empty_state_widget.dart';
import 'add_semester_screen.dart';
import 'semester_detail_screen.dart';

/// Halaman Daftar Semester.
class SemesterListScreen extends StatefulWidget {
  const SemesterListScreen({super.key});

  @override
  State<SemesterListScreen> createState() => _SemesterListScreenState();
}

class _SemesterListScreenState extends State<SemesterListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    final sem = context.read<SemesterProvider>();

    final userId = auth.userId;

    debugPrint('SEMESTER LIST USER ID: $userId');

    if (userId == null || userId.isEmpty) {
      debugPrint('USER ID masih null, semester tidak dimuat.');
      return;
    }

    await sem.loadAllData(userId);

    debugPrint('JUMLAH SEMESTER DI UI: ${sem.semesters.length}');
    debugPrint('ERROR SEMESTER: ${sem.error}');
  }

  Future<void> _openAddSemesterScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddSemesterScreen()),
    );

    if (!mounted) return;

    await _loadData();

    final sem = context.read<SemesterProvider>();
    debugPrint('SETELAH TAMBAH, JUMLAH SEMESTER: ${sem.semesters.length}');
  }

  void _showEditDialog(String semesterId, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Semester',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Nama semester',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
          ),
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final sem = Provider.of<SemesterProvider>(
                  context,
                  listen: false,
                );
                Navigator.pop(ctx);
                await sem.updateSemester(
                  auth.userId!,
                  semesterId,
                  controller.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Semester berhasil diupdate'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Simpan',
              style: GoogleFonts.poppins(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String semesterId, String semesterName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Semester',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "$semesterName"?\n\nSemua mata kuliah dalam semester ini juga akan dihapus.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final sem = Provider.of<SemesterProvider>(context, listen: false);
              Navigator.pop(ctx);
              await sem.deleteSemester(auth.userId!, semesterId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Semester berhasil dihapus'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Semester Saya',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<SemesterProvider>(
        builder: (context, semProvider, _) {
          if (semProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final errorMessage = semProvider.error;

          if (errorMessage != null && errorMessage.trim().isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat data semester',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(
                        'Coba Lagi',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (semProvider.semesters.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.school_rounded,
              title: 'Belum Ada Semester',
              subtitle:
                  'Tambahkan semester pertamamu\nuntuk mulai mencatat nilai.',
              buttonText: 'Tambah Semester',
              onButtonPressed: _openAddSemesterScreen,
            );
          }
          return RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: semProvider.semesters.length,
              itemBuilder: (context, index) {
                final s = semProvider.semesters[index];
                return SemesterCard(
                  semesterName: s.semesterName,
                  courseCount: semProvider.getSemesterCourseCount(s.id),
                  totalSKS: semProvider.getSemesterSKS(s.id),
                  ips: semProvider.getIPS(s.id),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SemesterDetailScreen(
                        semesterId: s.id,
                        semesterName: s.semesterName,
                      ),
                    ),
                  ).then((_) => _loadData()),
                  onEdit: () => _showEditDialog(s.id, s.semesterName),
                  onDelete: () => _showDeleteDialog(s.id, s.semesterName),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddSemesterScreen,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: AppColors.white),
        label: Text(
          'Tambah Semester',
          style: GoogleFonts.poppins(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
