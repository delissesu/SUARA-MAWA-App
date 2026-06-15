import 'package:flutter/material.dart';
import '../models/aspirasi_item.dart';

class StatusBadge extends StatelessWidget {
  final AspirasiStatus status;
  final int? reportId;

  const StatusBadge({super.key, required this.status, this.reportId});

  @override
  Widget build(BuildContext context) {
    if (status == AspirasiStatus.all) return const SizedBox.shrink();

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.badgeBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.badgeIcon, size: 12, color: status.badgeTextColor),
          const SizedBox(width: 5),
          Text(
            status.label,
            style: TextStyle(
              fontFamily: 'PublicSans',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: status.badgeTextColor,
            ),
          ),
        ],
      ),
    );

    if (reportId != null) {
      return Hero(
        tag: 'status-badge-$reportId',
        child: Material(
          color: Colors.transparent,
          child: badge,
        ),
      );
    }

    return badge;
  }
}
