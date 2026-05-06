import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/grade_calculator.dart';
import '../../providers/semester_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

/// Halaman Simulasi Target IPK.
class TargetIPKScreen extends StatefulWidget {
  const TargetIPKScreen({super.key});

  @override
  State<TargetIPKScreen> createState() => _TargetIPKScreenState();
}

class _TargetIPKScreenState extends State<TargetIPKScreen> {
  final _formKey = GlobalKey<FormState>();
  final _targetController = TextEditingController();
  final _sksController = TextEditingController();
  double? _result;

  @override
  void dispose() {
    _targetController.dispose();
    _sksController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final sem = Provider.of<SemesterProvider>(context, listen: false);
    final target = double.parse(_targetController.text);
    final plannedSKS = int.parse(_sksController.text);

    final neededAvg = GradeCalculator.simulateTargetIPK(
      currentTotalQualityPoints: sem.totalQualityPoints,
      currentTotalSKS: sem.totalSKS,
      targetIPK: target,
      plannedSKS: plannedSKS,
    );

    setState(() => _result = neededAvg);
  }

  String _getResultMessage(double result) {
    if (result > 4.0) return 'Target tidak dapat dicapai dengan jumlah SKS tersebut. Anda membutuhkan rata-rata di atas 4.00.';
    if (result < 0) return 'IPK Anda sudah melebihi target! Pertahankan prestasi Anda.';
    return 'Anda perlu mendapatkan rata-rata grade point minimal ${result.toStringAsFixed(2)} pada semester berikutnya.';
  }

  Color _getResultColor(double result) {
    if (result > 4.0) return AppColors.error;
    if (result < 0) return AppColors.success;
    if (result >= 3.5) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Simulasi Target IPK',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.white)),
        backgroundColor: AppColors.primary, elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Consumer<SemesterProvider>(
        builder: (context, sem, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Status Card
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient, borderRadius: BorderRadius.circular(20)),
                    child: Column(children: [
                      Text('Status Saat Ini', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.white.withValues(alpha: 0.8))),
                      const SizedBox(height: 8),
                      Text(GradeCalculator.formatGPA(sem.ipk),
                        style: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.white)),
                      Text('IPK Kumulatif', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.white.withValues(alpha: 0.6))),
                      const SizedBox(height: 12),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                        _buildStatusItem('Total SKS', '${sem.totalSKS}'),
                        _buildStatusItem('Total N.Mutu', sem.totalQualityPoints.toStringAsFixed(1)),
                        _buildStatusItem('Semester', '${sem.semesterCount}'),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  Text('Hitung Target', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text('Masukkan target IPK dan rencana SKS semester depan.',
                    style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _targetController, label: 'Target IPK', hint: 'Contoh: 3.50',
                    prefixIcon: Icons.flag_rounded, keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Target IPK tidak boleh kosong';
                      final val = double.tryParse(v);
                      if (val == null) return 'Masukkan angka yang valid';
                      if (val < 0 || val > 4.0) return 'IPK harus antara 0.00 - 4.00';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _sksController, label: 'Rencana SKS Semester Depan', hint: 'Contoh: 20',
                    prefixIcon: Icons.book_rounded, keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'SKS tidak boleh kosong';
                      final val = int.tryParse(v);
                      if (val == null) return 'Masukkan angka yang valid';
                      if (val <= 0) return 'SKS harus lebih dari 0';
                      if (val > 24) return 'SKS tidak boleh lebih dari 24';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  CustomButton(text: 'Hitung', onPressed: _calculate, icon: Icons.calculate_rounded),
                  const SizedBox(height: 24),
                  if (_result != null) _buildResultCard(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusItem(String label, String value) {
    return Column(children: [
      Text(value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white)),
      Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.white.withValues(alpha: 0.6))),
    ]);
  }

  Widget _buildResultCard() {
    final color = _getResultColor(_result!);
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(_result! > 4.0 ? Icons.warning_rounded : _result! < 0 ? Icons.celebration_rounded : Icons.check_circle_rounded,
            color: color, size: 24),
          const SizedBox(width: 8),
          Text('Hasil Simulasi', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: color)),
        ]),
        const SizedBox(height: 12),
        if (_result! >= 0 && _result! <= 4.0)
          Center(child: Text(_result!.toStringAsFixed(2),
            style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.bold, color: color))),
        const SizedBox(height: 8),
        Text(_getResultMessage(_result!), style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary)),
      ]),
    );
  }
}
