import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/aspirasi/beranda_mahasiswa/components/activity_card.dart';
import 'package:suara_mawa/screens/aspirasi/models/report_model.dart';

class RecentActivitySection extends StatelessWidget {
  final VoidCallback? onViewAll;
  final List<ReportListItem> recentItems;
  final bool isLoading;

  const RecentActivitySection({
    super.key,
    this.onViewAll,
    this.recentItems = const [],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aktivitas Terbaru',
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF0D1B2A),
              ),
            ),
            TextButton(
              onPressed: onViewAll ?? () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontFamily: 'PublicSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Color(0xFF5C6B8A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (recentItems.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.inbox_outlined, size: 40, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text(
                  'Belum ada aktivitas terbaru',
                  style: TextStyle(
                    fontFamily: 'PublicSans',
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          )
        else
          ...recentItems.asMap().entries.map((entry) {
            final item = entry.value;
            final statusLabel = _formatStatus(item.latestStatus);
            final statusColors = _statusColors(item.latestStatus);

            return Padding(
              padding: EdgeInsets.only(bottom: entry.key < recentItems.length - 1 ? 12 : 0),
              child: ActivityCard(
                iconBackgroundColor: statusColors.$3,
                icon: _categoryIcon(item.categoriesName),
                iconColor: statusColors.$2,
                title: item.title,
                timeAgo: item.categoriesName,
                description: item.description,
                statusLabel: statusLabel,
                statusColor: statusColors.$1,
                statusBgColor: statusColors.$3,
                statusIcon: _statusIcon(item.latestStatus),
              ),
            );
          }),
      ],
    );
  }

  String _formatStatus(String? status) {
    return switch (status?.toLowerCase()) {
      'pending' => 'Menunggu Verifikasi',
      'in_progress' => 'Sedang Diproses',
      'resolved' => 'Selesai',
      'revision' => 'Revisi',
      'rejected' => 'Ditolak',
      _ => 'Menunggu Verifikasi',
    };
  }

  (Color, Color, Color) _statusColors(String? status) {
    return switch (status?.toLowerCase()) {
      'pending' => (const Color(0xFF5C6B8A), const Color(0xFF5C6B8A), const Color(0xFFEDEEF2)),
      'in_progress' => (const Color(0xFF00838F), const Color(0xFF00838F), const Color(0xFFB2EBF2)),
      'resolved' => (const Color(0xFF52B788), const Color(0xFF52B788), const Color(0xFF1B4332)),
      'revision' => (const Color(0xFFFF9800), const Color(0xFFFF9800), const Color(0xFFFFF3E0)),
      'rejected' => (const Color(0xFFE53935), const Color(0xFFE53935), const Color(0xFFFFEBEE)),
      _ => (const Color(0xFF5C6B8A), const Color(0xFF5C6B8A), const Color(0xFFEDEEF2)),
    };
  }

  IconData _statusIcon(String? status) {
    return switch (status?.toLowerCase()) {
      'pending' => Icons.assignment_late_outlined,
      'in_progress' => Icons.sync_outlined,
      'resolved' => Icons.check_circle_outline,
      'revision' => Icons.replay_outlined,
      'rejected' => Icons.cancel_outlined,
      _ => Icons.assignment_late_outlined,
    };
  }

  IconData _categoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('prasarana') || lower.contains('fasilitas')) {
      return Icons.build_outlined;
    } else if (lower.contains('akademik') || lower.contains('mata kuliah')) {
      return Icons.menu_book_outlined;
    } else if (lower.contains('pengajar')) {
      return Icons.school_outlined;
    }
    return Icons.article_outlined;
  }
}
