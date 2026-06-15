import 'package:flutter/material.dart';
import '../models/detail_aspirasi_model.dart';

class DetailStatusBadge extends StatelessWidget {
  final DetailStatus status;

  const DetailStatusBadge({super.key, required this.status});

  Color get _bgColor {
    return switch (status) {
      DetailStatus.submitted => const Color(0xFFEDEEF2),
      DetailStatus.underReview => const Color(0xFFB2EBF2),
      DetailStatus.inProgress => const Color(0xFF1B4332),
      DetailStatus.resolved => const Color(0xFF0D1B6E),
    };
  }

  Color get _textColor {
    return switch (status) {
      DetailStatus.submitted => const Color(0xFF5C6B8A),
      DetailStatus.underReview => const Color(0xFF00838F),
      DetailStatus.inProgress => const Color(0xFF52B788),
      DetailStatus.resolved => Colors.white,
    };
  }

  IconData get _icon {
    return switch (status) {
      DetailStatus.submitted => Icons.assignment_late_outlined,
      DetailStatus.underReview => Icons.sync_rounded,
      DetailStatus.inProgress => Icons.sync_rounded,
      DetailStatus.resolved => Icons.check_circle_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 13, color: _textColor),
            const SizedBox(width: 6),
            Text(
              status.label,
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: _textColor,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
