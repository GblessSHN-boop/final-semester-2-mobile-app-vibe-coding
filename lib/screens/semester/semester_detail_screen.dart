import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/grade_calculator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../widgets/course_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../course/add_edit_course_screen.dart';

/// Halaman Detail Semester - Menampilkan daftar mata kuliah dan IPS.
class SemesterDetailScreen extends StatefulWidget {
  final String semesterId;
  final String semesterName;

  const SemesterDetailScreen({
    super.key,
    required this.semesterId,
    required this.semesterName,
  });

  @override
  State<SemesterDetailScreen> createState() => _SemesterDetailScreenState();
}

class _SemesterDetailScreenState extends State<SemesterDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final courseProvider = Provider.of<CourseProvider>(context, listen: false);
    if (auth.userId != null) {
      await courseProvider.loadCourses(auth.userId!, widget.semesterId);
    }
  }

  void _showDeleteDialog(String courseId, String courseName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Mata Kuliah', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Apakah Anda yakin ingin menghapus "$courseName"?', style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              final cp = Provider.of<CourseProvider>(context, listen: false);
              await cp.deleteCourse(courseId, auth.userId!, widget.semesterId);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('Mata kuliah berhasil dihapus'), backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Hapus', style: GoogleFonts.poppins(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<CourseProvider>(
        builder: (context, courseProvider, _) {
          final courses = courseProvider.courses;
          final ips = GradeCalculator.calculateIPS(courses);
          final totalSKS = GradeCalculator.calculateTotalSKS(courses);

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: AppColors.primary,
                iconTheme: const IconThemeData(color: AppColors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(widget.semesterName,
                              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.white)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildChip('${courses.length} MK', Icons.book_rounded),
                                const SizedBox(width: 12),
                                _buildChip('$totalSKS SKS', Icons.credit_card_rounded),
                                const SizedBox(width: 12),
                                _buildChip('IPS: ${GradeCalculator.formatGPA(ips)}', Icons.star_rounded),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Content
              if (courseProvider.isLoading)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
              else if (courses.isEmpty)
                SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.library_books_rounded,
                    title: 'Belum Ada Mata Kuliah',
                    subtitle: 'Tambahkan mata kuliah\nuntuk menghitung IPS semester ini.',
                    buttonText: 'Tambah Mata Kuliah',
                    onButtonPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => AddEditCourseScreen(semesterId: widget.semesterId),
                      )).then((_) => _loadCourses());
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildIPSCard(ips, totalSKS),
                          );
                        }
                        final course = courses[index - 1];
                        return CourseCard(
                          course: course,
                          onEdit: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => AddEditCourseScreen(semesterId: widget.semesterId, course: course),
                            )).then((_) => _loadCourses());
                          },
                          onDelete: () => _showDeleteDialog(course.id, course.courseName),
                        );
                      },
                      childCount: courses.length + 1,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => AddEditCourseScreen(semesterId: widget.semesterId),
          )).then((_) => _loadCourses());
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: AppColors.white),
      ),
    );
  }

  Widget _buildChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.white, size: 14),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildIPSCard(double ips, int totalSKS) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('IPS Semester', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.white.withValues(alpha: 0.8))),
            Text('Total $totalSKS SKS', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.white.withValues(alpha: 0.6))),
          ]),
          Text(GradeCalculator.formatGPA(ips), style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.white)),
        ],
      ),
    );
  }
}
