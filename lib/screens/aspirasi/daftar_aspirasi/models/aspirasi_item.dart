import 'package:flutter/material.dart';

enum AspirasiStatus {
  all,
  verification,
  inProgress,
  done;

  String get label {
    return switch (this) {
      AspirasiStatus.all => 'All',
      AspirasiStatus.verification => 'Verification',
      AspirasiStatus.inProgress => 'In Progress',
      AspirasiStatus.done => 'Done',
    };
  }

  /// Maps this UI enum to the backend status string(s).
  List<String> get apiValues {
    return switch (this) {
      AspirasiStatus.all => [],
      AspirasiStatus.verification => ['pending', 'revision'],
      AspirasiStatus.inProgress => ['in_progress'],
      AspirasiStatus.done => ['resolved', 'rejected'],
    };
  }

  /// Returns the matching [AspirasiStatus] for a backend status string.
  static AspirasiStatus fromApiStatus(String? apiStatus) {
    return switch (apiStatus?.toLowerCase()) {
      'pending' || 'revision' => AspirasiStatus.verification,
      'in_progress' => AspirasiStatus.inProgress,
      'resolved' || 'rejected' => AspirasiStatus.done,
      _ => AspirasiStatus.verification,
    };
  }

  Color get badgeBackgroundColor {
    return switch (this) {
      AspirasiStatus.all => const Color(0xFF00BFA5),
      AspirasiStatus.verification => const Color(0xFFEDEEF2),
      AspirasiStatus.inProgress => const Color(0xFF1B4332),
      AspirasiStatus.done => const Color(0xFF0D1B6E),
    };
  }

  Color get badgeTextColor {
    return switch (this) {
      AspirasiStatus.all => Colors.white,
      AspirasiStatus.verification => const Color(0xFF5C6B8A),
      AspirasiStatus.inProgress => const Color(0xFF52B788),
      AspirasiStatus.done => Colors.white,
    };
  }

  Color get accentBorderColor {
    return switch (this) {
      AspirasiStatus.all => const Color(0xFF00BFA5),
      AspirasiStatus.verification => const Color(0xFFB0BEC5),
      AspirasiStatus.inProgress => const Color(0xFF52B788),
      AspirasiStatus.done => const Color(0xFF0D1B6E),
    };
  }

  IconData get badgeIcon {
    return switch (this) {
      AspirasiStatus.all => Icons.check_circle_outline,
      AspirasiStatus.verification => Icons.assignment_late_outlined,
      AspirasiStatus.inProgress => Icons.sync_rounded,
      AspirasiStatus.done => Icons.check_circle_outline,
    };
  }
}

class AspirasiItem {
  final int reportId;
  final String id;
  final String title;
  final String description;
  final String category;
  final String dateLabel;
  final AspirasiStatus status;

  const AspirasiItem({
    required this.reportId,
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dateLabel,
    required this.status,
  });
}
