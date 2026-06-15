import 'package:flutter/material.dart';
import '../models/detail_aspirasi_model.dart';
import '../components/detail_status_badge.dart';

class DetailHeaderSection extends StatelessWidget {
  final DetailAspirasiModel item;

  const DetailHeaderSection({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category chip + date row
        Row(
          children: [
            _CategoryChip(label: item.category),
            const SizedBox(width: 10),
            Icon(
              Icons.calendar_today_outlined,
              size: 13,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 4),
            Text(
              item.dateLabel,
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // ID
        Text(
          '# ${item.aspirationId}',
          style: TextStyle(
            fontFamily: 'PublicSans',
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 6),
        // Title
        Text(
          item.title,
          style: const TextStyle(
            fontFamily: 'PublicSans',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            height: 1.3,
            color: Color(0xFF0D1B2A),
          ),
        ),
        const SizedBox(height: 12),
        // Status badge with Hero transition
        Hero(
          tag: 'status-badge-${item.reportId}',
          child: Material(
            color: Colors.transparent,
            child: DetailStatusBadge(status: item.currentStatus),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;

  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFB2EBF2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.construction_outlined,
            size: 12,
            color: Color(0xFF00838F),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'PublicSans',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Color(0xFF00838F),
            ),
          ),
        ],
      ),
    );
  }
}
