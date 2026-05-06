import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/semester_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Halaman Tambah Semester baru.
class AddSemesterScreen extends StatefulWidget {
  const AddSemesterScreen({super.key});

  @override
  State<AddSemesterScreen> createState() => _AddSemesterScreenState();
}

class _AddSemesterScreenState extends State<AddSemesterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final sem = Provider.of<SemesterProvider>(context, listen: false);
    final success = await sem.addSemester(auth.userId!, _nameController.text);
    setState(() => _isLoading = false);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Semester berhasil ditambahkan'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
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
        title: Text('Tambah Semester',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.white)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Buat semester baru untuk mulai mencatat mata kuliah.',
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _nameController,
                label: 'Nama Semester',
                hint: 'Contoh: Semester 1',
                prefixIcon: Icons.school_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Nama semester tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              CustomButton(text: 'Simpan Semester', isLoading: _isLoading, onPressed: _handleAdd, icon: Icons.save_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
