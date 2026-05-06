import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/grade_data.dart';
import '../../models/course_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Halaman Tambah/Edit Mata Kuliah.
class AddEditCourseScreen extends StatefulWidget {
  final String semesterId;
  final CourseModel? course; // null = tambah baru, non-null = edit

  const AddEditCourseScreen({
    super.key,
    required this.semesterId,
    this.course,
  });

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sksController = TextEditingController();
  String? _selectedGrade;
  bool _isLoading = false;

  bool get isEditing => widget.course != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _nameController.text = widget.course!.courseName;
      _sksController.text = widget.course!.sks.toString();
      _selectedGrade = widget.course!.gradeLetter;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sksController.dispose();
    super.dispose();
  }

  double get _previewQualityPoint {
    final sks = int.tryParse(_sksController.text) ?? 0;
    if (_selectedGrade == null || sks <= 0) return 0;
    return GradeData.calculateQualityPoint(sks, _selectedGrade!);
  }

  double get _previewGradePoint {
    if (_selectedGrade == null) return 0;
    return GradeData.getGradePoint(_selectedGrade!);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGrade == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Pilih nilai huruf terlebih dahulu'),
          backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      );
      return;
    }

    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final cp = Provider.of<CourseProvider>(context, listen: false);
    bool success;

    if (isEditing) {
      success = await cp.updateCourse(
        courseId: widget.course!.id,
        userId: auth.userId!,
        semesterId: widget.semesterId,
        courseName: _nameController.text,
        sks: int.parse(_sksController.text),
        gradeLetter: _selectedGrade!,
      );
    } else {
      success = await cp.addCourse(
        userId: auth.userId!,
        semesterId: widget.semesterId,
        courseName: _nameController.text,
        sks: int.parse(_sksController.text),
        gradeLetter: _selectedGrade!,
      );
    }

    setState(() => _isLoading = false);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Mata kuliah berhasil diupdate' : 'Mata kuliah berhasil ditambahkan'),
          backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Mata Kuliah' : 'Tambah Mata Kuliah',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.white)),
        backgroundColor: AppColors.primary, elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Nama Mata Kuliah',
                hint: 'Contoh: Pemrograman Web',
                prefixIcon: Icons.book_rounded,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Nama mata kuliah tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: _sksController,
                label: 'Jumlah SKS',
                hint: 'Contoh: 3',
                prefixIcon: Icons.numbers_rounded,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'SKS tidak boleh kosong';
                  final sks = int.tryParse(v);
                  if (sks == null) return 'SKS harus berupa angka';
                  if (sks <= 0) return 'SKS harus lebih dari 0';
                  if (sks > 8) return 'SKS tidak boleh lebih dari 8';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Grade Dropdown
              Text('Nilai Huruf', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedGrade,
                decoration: InputDecoration(
                  hintText: 'Pilih nilai huruf',
                  hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textHint),
                  filled: true, fillColor: AppColors.greyLight,
                  prefixIcon: const Icon(Icons.grade_rounded, color: AppColors.greyDark, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accent, width: 2)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
                ),
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary),
                items: GradeData.gradeLetters.map((grade) {
                  return DropdownMenuItem(
                    value: grade,
                    child: Text('$grade (${GradeData.getGradePoint(grade).toStringAsFixed(2)})',
                      style: GoogleFonts.poppins(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedGrade = v),
                validator: (v) => v == null ? 'Nilai huruf wajib dipilih' : null,
              ),
              const SizedBox(height: 24),
              // Preview
              if (_selectedGrade != null && _sksController.text.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.infoLight, borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Text('Preview Perhitungan', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                        _buildPreviewItem('Bobot', _previewGradePoint.toStringAsFixed(2)),
                        _buildPreviewItem('SKS', _sksController.text),
                        _buildPreviewItem('N. Mutu', _previewQualityPoint.toStringAsFixed(2)),
                      ]),
                      const SizedBox(height: 8),
                      Text('Nilai Mutu = SKS × Bobot = ${_sksController.text} × ${_previewGradePoint.toStringAsFixed(2)} = ${_previewQualityPoint.toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              CustomButton(text: isEditing ? 'Update Mata Kuliah' : 'Simpan Mata Kuliah',
                isLoading: _isLoading, onPressed: _handleSave, icon: Icons.save_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Column(children: [
      Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
      Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
    ]);
  }
}
