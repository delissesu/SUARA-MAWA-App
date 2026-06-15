import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:suara_mawa/utils/app_colors.dart';
import 'package:suara_mawa/screens/penindak/task_detail_screen.dart';
import 'package:suara_mawa/screens/penindak/services/report_service.dart';
import 'package:suara_mawa/screens/penindak/models/report.dart';

class AdminDaftarAspirasiScreen extends StatefulWidget {
  const AdminDaftarAspirasiScreen({super.key});

  @override
  State<AdminDaftarAspirasiScreen> createState() =>
      _AdminDaftarAspirasiScreenState();
}

class _AdminDaftarAspirasiScreenState extends State<AdminDaftarAspirasiScreen> {
  int _selectedTabIndex = 0;

  final ReportService _reportService = ReportService();

  // Data per tab
  List<Report> _inProgressReports = [];
  List<Report> _revisionReports = [];
  List<Report> _resolvedReports = [];

  bool _isLoading = true;
  String? _errorMessage;

  // Status mapping for each tab
  static const List<Map<String, dynamic>> _tabMeta = [
    {
      'title': 'Perlu Dikerjakan',
      'icon': Icons.list_alt,
      'status': 'in_progress',
      'buttonLabel': 'Lihat Detail',
    },
    {
      'title': 'Perlu Revisi',
      'icon': Icons.autorenew,
      'status': 'revision',
      'buttonLabel': 'Lihat Detail',
    },
    {
      'title': 'Selesai',
      'icon': Icons.check_circle_outline,
      'status': 'resolved',
      'buttonLabel': 'Lihat Detail',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch reports for both departmentId 1 and 2, all statuses
      final results = await Future.wait([
        _reportService.fetchReports(departmentId: 1, status: 'pending'),
        _reportService.fetchReports(departmentId: 1, status: 'in_progress'),
        _reportService.fetchReports(departmentId: 1, status: 'revision'),
        _reportService.fetchReports(departmentId: 1, status: 'resolved'),
        _reportService.fetchReports(departmentId: 2, status: 'pending'),
        _reportService.fetchReports(departmentId: 2, status: 'in_progress'),
        _reportService.fetchReports(departmentId: 2, status: 'revision'),
        _reportService.fetchReports(departmentId: 2, status: 'resolved'),
      ]);

      // Merge dept 1 + dept 2 per status
      final inProgress = [...results[0], ...results[1], ...results[4], ...results[5]];
      final revision = [...results[2], ...results[6]];
      final resolved = [...results[3], ...results[7]];

      // Sort each by createdAt descending
      inProgress.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      revision.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      resolved.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _inProgressReports = inProgress;
        _revisionReports = revision;
        _resolvedReports = resolved;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan saat memuat data.';
      });
    }
  }

  List<Report> get _currentReports {
    switch (_selectedTabIndex) {
      case 0:
        return _inProgressReports;
      case 1:
        return _revisionReports;
      case 2:
        return _resolvedReports;
      default:
        return [];
    }
  }

  String _getCountText(int index) {
    switch (index) {
      case 0:
        return _inProgressReports.length.toString();
      case 1:
        return _revisionReports.length.toString();
      case 2:
        return _resolvedReports.length.toString();
      default:
        return '0';
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
    return '${(diff.inDays / 30).floor()} bulan lalu';
  }

  String _getTimeLabel(int tabIndex, DateTime createdAt) {
    final timeAgo = _formatTimeAgo(createdAt);
    switch (tabIndex) {
      case 0:
        return 'Dilaporkan $timeAgo';
      case 1:
        return 'Diperbarui $timeAgo';
      case 2:
        return 'Diselesaikan $timeAgo';
      default:
        return timeAgo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadReports,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCustomTabs(),
                  const SizedBox(height: 24),
                  _buildTabContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_tabMeta.length, (index) {
          final isSelected = _selectedTabIndex == index;
          final tab = _tabMeta[index];
          final count = _isLoading ? '...' : _getCountText(index);

          final String displayText = "${tab['title']} ($count)";

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tab['icon'],
                      size: 20,
                      color:
                          isSelected ? AppColors.white : AppColors.inactive,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.inactive,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadReports,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final reports = _currentReports;

    if (reports.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Belum ada laporan pada tab ini.',
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final buttonLabel =
        _tabMeta[_selectedTabIndex]['buttonLabel'] as String;

    return Column(
      children: reports.map((report) {
        return _buildTaskCard(
          thumbnailPath: report.thumbnail,
          title: report.title,
          category: report.categoriesName,
          description: report.description,
          timeAgo: _getTimeLabel(_selectedTabIndex, report.createdAt),
          buttonLabel: buttonLabel,
          onActionPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TaskDetailScreen(reportId: report.id)),
            );
          },
          onCardTapped: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      TaskDetailScreen(reportId: report.id)),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildTaskCard({
    required String? thumbnailPath,
    required String title,
    required String category,
    required String description,
    required String timeAgo,
    required String buttonLabel,
    required VoidCallback onActionPressed,
    required VoidCallback onCardTapped,
  }) {
    return GestureDetector(
      onTap: onCardTapped,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: thumbnailPath != null
                      ? _buildAuthenticatedImage(thumbnailPath)
                      : Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported,
                              size: 50, color: Colors.grey),
                        ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.category,
                          size: 18, color: AppColors.inactive),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.inactive,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.subtext1,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.inactive,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onActionPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                        ),
                        child: Text(
                          buttonLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticatedImage(String thumbnailPath) {
    return FutureBuilder<Uint8List?>(
      future: _reportService.fetchThumbnailBytes(thumbnailPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 180,
            width: double.infinity,
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 180,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported,
                  size: 50, color: Colors.grey),
            ),
          );
        }

        return Container(
          height: 180,
          width: double.infinity,
          color: Colors.grey[300],
          child: const Icon(Icons.image_not_supported,
              size: 50, color: Colors.grey),
        );
      },
    );
  }
}
