import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/grade_calculator.dart';
import '../../providers/auth_provider.dart';
import '../../providers/semester_provider.dart';
import '../../widgets/empty_state_widget.dart';
import 'target_ipk_screen.dart';

/// Halaman Statistik Akademik - Grafik IPS, IPS tertinggi/terendah, total SKS.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Statistik Akademik',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.white)),
        backgroundColor: AppColors.primary, elevation: 0, automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.track_changes_rounded, color: AppColors.white),
            tooltip: 'Simulasi Target IPK',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TargetIPKScreen())),
          ),
        ],
      ),
      body: Consumer<SemesterProvider>(
        builder: (context, sem, _) {
          if (sem.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final ipsData = sem.getIPSPerSemester();
          final hasData = ipsData.any((d) => (d['ips'] as double) > 0);

          if (!hasData) {
            return EmptyStateWidget(
              icon: Icons.bar_chart_rounded,
              title: 'Belum Ada Data Statistik',
              subtitle: 'Tambahkan semester dan mata kuliah\nuntuk melihat statistik akademik.',
            );
          }

          final highest = sem.getHighestIPSSemester();
          final lowest = sem.getLowestIPSSemester();

          return RefreshIndicator(
            onRefresh: _loadData,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // IPS Chart
                  _buildChartCard(ipsData),
                  const SizedBox(height: 20),
                  // Stats Row
                  Row(children: [
                    Expanded(child: _buildStatCard('IPS Tertinggi',
                      highest != null ? GradeCalculator.formatGPA(highest['ips']) : '-',
                      highest?['semesterName'] ?? '-', AppColors.success, Icons.trending_up_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('IPS Terendah',
                      lowest != null ? GradeCalculator.formatGPA(lowest['ips']) : '-',
                      lowest?['semesterName'] ?? '-', AppColors.error, Icons.trending_down_rounded)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _buildStatCard('Total SKS', '${sem.totalSKS}', 'Kumulatif', AppColors.accent, Icons.book_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('IPK', GradeCalculator.formatGPA(sem.ipk),
                      GradeCalculator.getIPKPredikat(sem.ipk), AppColors.primaryDark, Icons.school_rounded)),
                  ]),
                  const SizedBox(height: 20),
                  // Target IPK Button
                  _buildTargetIPKButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChartCard(List<Map<String, dynamic>> ipsData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Perkembangan IPS', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text('Grafik IPS per semester', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 4.0,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.primaryDark,
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, gi, rod, ri) {
                      final name = ipsData[group.x.toInt()]['semesterName'];
                      return BarTooltipItem('$name\n${rod.toY.toStringAsFixed(2)}',
                        GoogleFonts.poppins(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600));
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true, reservedSize: 36,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx >= 0 && idx < ipsData.length) {
                        final name = ipsData[idx]['semesterName'] as String;
                        final short = name.length > 5 ? 'S${idx + 1}' : name;
                        return Padding(padding: const EdgeInsets.only(top: 8),
                          child: Text(short, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary)));
                      }
                      return const SizedBox.shrink();
                    },
                  )),
                  leftTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true, reservedSize: 32, interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Text(value.toInt().toString(),
                        style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary));
                    },
                  )),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true, drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(color: AppColors.greyLight, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(ipsData.length, (i) {
                  final ips = ipsData[i]['ips'] as double;
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                      toY: ips, width: 24,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter, end: Alignment.topCenter,
                        colors: [AppColors.accent, AppColors.primaryLight],
                      ),
                    ),
                  ]);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 10),
        Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        Text(title, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
        Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _buildTargetIPKButton() {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TargetIPKScreen())),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient, borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.track_changes_rounded, color: AppColors.white, size: 24)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Simulasi Target IPK', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.white)),
            Text('Hitung nilai yang dibutuhkan', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.white.withValues(alpha: 0.7))),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.white, size: 18),
        ]),
      ),
    );
  }
}
