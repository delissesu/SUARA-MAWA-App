import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:suara_mawa/screens/admin/admin_account_management.dart';
import 'package:suara_mawa/screens/admin/admin_daftar_aspirasi_screen.dart';
import 'package:suara_mawa/screens/penindak/services/report_service.dart';
import 'package:suara_mawa/screens/penindak/models/report.dart';
import 'package:suara_mawa/screens/penindak/task_detail_screen.dart';
import 'package:suara_mawa/utils/app_colors.dart';
import 'package:suara_mawa/widgets/shared_main_screen.dart';
import 'package:suara_mawa/screens/aspirasi/profile/profile_screen.dart';

// Legacy constants used by other admin screens (admin_fullmap, admin_all_aspirasi, etc.)
const kNavy = Color(0xFF1A2C5B);
const kTeal = Color(0xFF4DD0C4);
const kRed = Color(0xFFE53935);
const kBg = Color(0xFFF5F6FA);

class AspirasiItem {
  final String judul, deskripsi, status, waktu, lokasi, pelapor;
  final IconData icon;
  final Color iconBg, iconColor, statusBg, statusColor;
  final IconData statusIcon;

  const AspirasiItem({
    required this.judul,
    required this.deskripsi,
    required this.status,
    required this.waktu,
    required this.lokasi,
    required this.pelapor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.statusBg,
    required this.statusColor,
    required this.statusIcon,
  });
}

final List<AspirasiItem> daftarAspirasi = [
  AspirasiItem(
    judul: 'Wifi mati loh yah',
    deskripsi:
        'Wifi di beberapa titik kampus mati sejak pagi, mohon dicek ya...',
    lokasi: 'Gedung A – Lantai 2',
    pelapor: 'Budi Santoso',
    status: 'Belum Terbaca',
    waktu: '10 menit yang lalu',
    icon: Icons.wifi_off_outlined,
    iconBg: const Color(0xFFB2EBF2),
    iconColor: const Color(0xFF00838F),
    statusBg: const Color(0xFFB2EBF2),
    statusColor: const Color(0xFF00838F),
    statusIcon: Icons.circle_outlined,
  ),
  AspirasiItem(
    judul: 'Jalan berlubang',
    deskripsi:
        'Jalan di depan gedung A banyak lubang, bahaya untuk pejalan kaki.',
    lokasi: 'Depan Gedung A',
    pelapor: 'Siti Rahayu',
    status: 'Proses',
    waktu: '2 jam yang lalu',
    icon: Icons.warning_amber_outlined,
    iconBg: const Color(0xFFFFEBEE),
    iconColor: kRed,
    statusBg: const Color(0xFFEEEEEE),
    statusColor: const Color(0xFF757575),
    statusIcon: Icons.schedule_outlined,
  ),
  AspirasiItem(
    judul: 'Gedung kena meteor',
    deskripsi:
        'Gedung B kena meteor kecil, ada kerusakan di atap dan beberapa jendela pecah.',
    lokasi: 'Gedung B – Atap',
    pelapor: 'Agus Wijaya',
    status: 'Selesai',
    waktu: '1 hari yang lalu',
    icon: Icons.restaurant_outlined,
    iconBg: const Color(0xFFEEEEEE),
    iconColor: const Color(0xFF424242),
    statusBg: const Color(0xFF1A3C34),
    statusColor: Colors.white,
    statusIcon: Icons.check_box_outlined,
  ),
];


class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return const SharedMainScreen(
      screens: [
        _AdminDashboardBody(),
        AdminDaftarAspirasiScreen(),
        AdminAccountManagement(),
        ProfileScreen(),
      ],
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt),
          label: 'Daftar Aspirasi',
        ),
        NavigationDestination(
          icon: Icon(Icons.manage_accounts_outlined),
          selectedIcon: Icon(Icons.manage_accounts),
          label: 'Akun',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}

class _AdminDashboardBody extends StatefulWidget {
  const _AdminDashboardBody();

  @override
  State<_AdminDashboardBody> createState() => _AdminDashboardBodyState();
}

class _AdminDashboardBodyState extends State<_AdminDashboardBody> {
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
      final allReports = await _reportService.fetchAllReports();
      allReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Compute stats from latestStatus
      final inProgressCount =
          allReports.where((r) => r.latestStatus == 'in_progress' || r.latestStatus == 'pending').length;
      final revisionCount =
          allReports.where((r) => r.latestStatus == 'revision').length;
      final resolvedCount =
          allReports.where((r) => r.latestStatus == 'resolved').length;

      // Fetch details for location data
      final detailedReports =
          await Future.wait(allReports.map((report) async {
        final detail = await _reportService.fetchReportDetail(report.id);
        if (detail != null) {
          final lat = (detail['locationLat'] as num?)?.toDouble();
          final lng = (detail['locationLong'] as num?)?.toDouble();
          final loc = detail['location'] as String?;
          return report.copyWith(
              locationLat: lat, locationLong: lng, location: loc);
        }
        return report;
      }));

      setState(() {
        _perluDikerjakan = inProgressCount;
        _perluRevisi = revisionCount;
        _selesai = resolvedCount;
        _totalAspirasi = allReports.length;
        _allReports = detailedReports;
        _recentReports = detailedReports.take(3).toList();
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error in _loadDashboardData: $e');
      print(stackTrace);
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan saat memuat data: $e';
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMapSection(),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      ),
                    )
                  else if (_errorMessage != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[600]),
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
        title: Text(report.title,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Kategori: ${report.categoriesName}",
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text("Lokasi: ${report.location ?? '-'}",
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text(report.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14)),
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
                MaterialPageRoute(
                    builder: (context) =>
                        TaskDetailScreen(reportId: report.id)),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            child: const Text("Detail"),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    final markers = _allReports
        .where((r) => r.locationLat != null && r.locationLong != null)
        .map((report) {
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
                initialCenter: LatLng(-8.165049, 113.716424),
                initialZoom: 15.0,
                maxZoom: 18.0,
                minZoom: 3.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
            style:
                TextStyle(fontSize: 14, color: textColor.withOpacity(0.8)),
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
              MaterialPageRoute(
                  builder: (context) => const AdminDaftarAspirasiScreen()),
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
              Icon(Icons.arrow_forward,
                  size: 16, color: AppColors.primary),
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
                style:
                    TextStyle(fontSize: 14, color: AppColors.inactive),
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
                        builder: (context) =>
                            TaskDetailScreen(reportId: reportId),
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
