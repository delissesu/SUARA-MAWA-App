import 'package:flutter/material.dart';
import '../models/aspirasi_item.dart';
import 'status_badge.dart';
import 'category_chip.dart';

class AspirasiCard extends StatelessWidget {
  final AspirasiItem item;
  final VoidCallback? onViewDetails;

  const AspirasiCard({super.key, required this.item, this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: item.status.accentBorderColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge + date row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(status: item.status),
                Text(
                  item.dateLabel,
                  style: TextStyle(
                    fontFamily: 'PublicSans',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              item.title,
              style: const TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                height: 1.3,
                color: Color(0xFF0D1B2A),
              ),
            ),
            const SizedBox(height: 6),
            // Description
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.w400,
                fontSize: 13,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 10),
            // Category + View Details row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CategoryChip(label: item.category),
                GestureDetector(
                  onTap: onViewDetails,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Lihat Detail',
                        style: TextStyle(
                          fontFamily: 'PublicSans',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1A2B5F),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: Color(0xFF1A2B5F),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
