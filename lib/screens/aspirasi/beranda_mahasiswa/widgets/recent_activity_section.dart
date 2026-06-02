import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/aspirasi/beranda_mahasiswa/components/activity_card.dart';

class RecentActivitySection extends StatelessWidget {
  final VoidCallback? onViewAll;

  const RecentActivitySection({super.key, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
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
                'View All',
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
        const ActivityCard(
          iconBackgroundColor: Color(0xFFB2EBF2),
          icon: Icons.build_outlined,
          iconColor: Color(0xFF00838F),
          title: 'Broken AC in Room 302',
          timeAgo: '2h ago',
          description: 'The air conditioning unit in classroom ...',
          statusLabel: 'Pending Review',
          statusColor: Color(0xFF5C6B8A),
          statusBgColor: Color(0xFFEDEEF2),
          statusIcon: Icons.assignment_late_outlined,
        ),
        const SizedBox(height: 12),
        const ActivityCard(
          iconBackgroundColor: Color(0xFF1B4332),
          icon: Icons.menu_book_outlined,
          iconColor: Color(0xFF52B788),
          title: 'Library Extended Hours ...',
          timeAgo: 'Yesterday',
          description: 'Requesting extended library hours duri...',
          statusLabel: 'Processed',
          statusColor: Color(0xFF00838F),
          statusBgColor: Color(0xFFB2EBF2),
          statusIcon: Icons.sync_outlined,
        ),
      ],
    );
  }
}
