import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:suara_mawa/utils/app_colors.dart';
import 'package:suara_mawa/screens/penindak/services/report_service.dart';
import 'package:suara_mawa/screens/penindak/models/report.dart';
import 'package:suara_mawa/screens/penindak/task_detail_screen.dart';
import 'package:suara_mawa/screens/penindak/task_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ReportService _reportService = ReportService();
  bool _isLoading = true;
  String? _errorMessage;

  int _totalAspirasi = 0;
  int _perluDikerjakan = 0;
  int _perluRevisi = 0;
  int _selesai = 0;

  List<Report> _recentReports = [];

  List<Report> _allReports = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final departmentId = await _reportService.getUserDepartmentId();
      if (departmentId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Gagal mendapatkan data departemen pengguna.';
        });
        return;
      }

      final results = await Future.wait([
        _reportService.fetchReports(departmentId: departmentId, status: 'in_progress'),
        _reportService.fetchReports(departmentId: departmentId, status: 'revision'),
        _reportService.fetchReports(departmentId: departmentId, status: 'resolved'),
      ]);

      final inProgress = results[0];
      final revision = results[1];
      final resolved = results[2];

      final allReports = [...inProgress, ...revision, ...resolved];
      allReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Fetch details for all reports to get location
      final detailedReports = await Future.wait(allReports.map((report) async {
        final detail = await _reportService.fetchReportDetail(report.id);
        if (detail != null) {
          final lat = (detail['locationLat'] as num?)?.toDouble();
          final lng = (detail['locationLong'] as num?)?.toDouble();
          return report.copyWith(locationLat: lat, locationLong: lng);
        }
        return report;
      }));

      setState(() {
        _perluDikerjakan = inProgress.length;
        _perluRevisi = revision.length;
        _selesai = resolved.length;
        _totalAspirasi = _perluDikerjakan + _perluRevisi + _selesai;
        _allReports = detailedReports;
        _recentReports = detailedReports.take(3).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan saat memuat data.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMapSection(),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (_errorMessage != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    _buildStatsSection(),
                    const SizedBox(height: 32),
                    _buildInterventionsHeader(),
                    const SizedBox(height: 16),
                    _buildInterventionsList(),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMarkerPopup(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Kategori: ${report.categoriesName}", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text(report.description, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskDetailScreen(reportId: report.id)),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text("Detail"),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    final markers = _allReports.where((r) => r.locationLat != null && r.locationLong != null).map((report) {
      return Marker(
        point: LatLng(report.locationLat!, report.locationLong!),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showMarkerPopup(report),
          child: Icon(
            Icons.location_pin,
            color: Colors.red[700],
            size: 40,
          ),
        ),
      );
    }).toList();

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(-6.186486, 106.829140),
                initialZoom: 13.0,
                maxZoom: 18.0,
                minZoom: 3.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.suara.app',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: "Total Aspirasi",
                number: _totalAspirasi.toString(),
                icon: Icons.assignment_outlined,
                bgColor: AppColors.activePrimary,
                iconBgColor: AppColors.background,
                iconColor: AppColors.primary,
                textColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: "Perlu Dikerjakan",
                number: _perluDikerjakan.toString(),
                icon: Icons.hourglass_top_outlined,
                bgColor: AppColors.activePrimary,
                iconBgColor: AppColors.background,
                iconColor: AppColors.primary,
                textColor: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: "Perlu Revisi",
                number: _perluRevisi.toString(),
                icon: Icons.assignment_outlined,
                bgColor: AppColors.activePrimary,
                iconBgColor: AppColors.background,
                iconColor: AppColors.primary,
                textColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: "Selesai",
                number: _selesai.toString(),
                icon: Icons.check,
                bgColor: AppColors.activePrimary,
                iconBgColor: AppColors.background,
                iconColor: AppColors.primary,
                textColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String number,
    required IconData icon,
    required Color bgColor,
    required Color iconBgColor,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildInterventionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Aspirasi terbaru",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TaskListScreen()),
            );
          },
          child: Row(
            children: [
              Text(
                "Lihat Semua",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInterventionsList() {
    if (_recentReports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Belum ada aspirasi terbaru.",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Column(
      children: _recentReports.map((report) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildInterventionCard(
            reportId: report.id,
            title: report.title,
            category: report.categoriesName,
            description: report.description,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInterventionCard({
    required int reportId,
    required String title,
    required String category,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.category, size: 16, color: AppColors.inactive),
              const SizedBox(width: 4),
              Text(
                category,
                style: TextStyle(fontSize: 14, color: AppColors.inactive),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.subtext1,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailScreen(reportId: reportId),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    side: const BorderSide(color: Colors.grey),
                  ),
                  child: const Text(
                    "Detail",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
