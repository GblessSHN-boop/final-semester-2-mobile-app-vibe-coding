import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/grade_data.dart';
import '../models/course_model.dart';

/// Card untuk menampilkan informasi mata kuliah.
class CourseCard extends StatelessWidget {
  final CourseModel course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CourseCard({
    super.key,
    required this.course,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getGradeColor(String gradeLetter) {
    final category = GradeData.getGradeCategory(gradeLetter);
    switch (category) {
      case 'excellent':
        return AppColors.success;
      case 'good':
        return AppColors.accent;
      case 'average':
        return AppColors.warning;
      case 'below_average':
        return const Color(0xFFFF7043);
      case 'fail':
        return AppColors.error;
      default:
        return AppColors.greyDark;
    }
  }

  Color _getGradeBgColor(String gradeLetter) {
    final category = GradeData.getGradeCategory(gradeLetter);
    switch (category) {
      case 'excellent':
        return AppColors.successLight;
      case 'good':
        return AppColors.infoLight;
      case 'average':
        return AppColors.warningLight;
      case 'below_average':
        return const Color(0xFFFBE9E7);
      case 'fail':
        return AppColors.errorLight;
      default:
        return AppColors.greyLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Grade Badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _getGradeBgColor(course.gradeLetter),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  course.gradeLetter,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getGradeColor(course.gradeLetter),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Course Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.courseName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildInfoChip(
                        '${course.sks} SKS',
                        Icons.book_rounded,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        'Bobot: ${course.gradePoint.toStringAsFixed(2)}',
                        Icons.star_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Nilai Mutu: ${course.qualityPoint.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            // Actions
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.greyDark,
                size: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_rounded,
                          size: 18, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text('Edit', style: GoogleFonts.poppins(fontSize: 14)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_rounded,
                          size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text('Hapus',
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
