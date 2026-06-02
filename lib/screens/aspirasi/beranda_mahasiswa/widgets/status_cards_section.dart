import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/aspirasi/beranda_mahasiswa/components/status_card.dart';

class StatusCardsSection extends StatelessWidget {
  final int pendingCount;
  final int processedCount;
  final int resolvedCount;

  const StatusCardsSection({
    super.key,
    required this.pendingCount,
    required this.processedCount,
    required this.resolvedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatusCard(
                label: 'Pending',
                count: pendingCount,
                icon: Icons.assignment_late_outlined,
                backgroundColor: const Color(0xFFEDEEF2),
                textColor: const Color(0xFF0D1B2A),
                iconColor: const Color(0xFF5C6B8A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatusCard(
                label: 'Processed',
                count: processedCount,
                icon: Icons.sync_outlined,
                backgroundColor: const Color(0xFFB2EBF2),
                textColor: const Color(0xFF00838F),
                iconColor: const Color(0xFF00838F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StatusCard(
          label: 'Resolved',
          count: resolvedCount,
          icon: Icons.check_circle_outline,
          backgroundColor: const Color(0xFF1B4332),
          textColor: const Color(0xFF52B788),
          iconColor: const Color(0xFF52B788),
          isWide: true,
        ),
      ],
    );
  }
}
