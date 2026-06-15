import 'package:flutter/material.dart';

// Re-export or mirror AspirasiStatus from daftar_aspirasi if shared
// For independence, we define status here too. In production, extract
// both to a shared lib/models/ folder and import from there.
enum DetailStatus {
  submitted,
  underReview,
  inProgress,
  resolved;

  String get label {
    return switch (this) {
      DetailStatus.submitted => 'Terkirim',
      DetailStatus.underReview => 'Verifikasi',
      DetailStatus.inProgress => 'Sedang Diproses',
      DetailStatus.resolved => 'Selesai',
    };
  }

  /// Maps a backend status string to this UI enum.
  static DetailStatus fromApiStatus(String apiStatus) {
    return switch (apiStatus.toLowerCase()) {
      'pending' => DetailStatus.submitted,
      'revision' => DetailStatus.underReview,
      'in_progress' => DetailStatus.inProgress,
      'resolved' || 'rejected' => DetailStatus.resolved,
      _ => DetailStatus.submitted,
    };
  }

  Color get activeIconBg {
    return switch (this) {
      DetailStatus.submitted => const Color(0xFF1A2B5F),
      DetailStatus.underReview => const Color(0xFF1A2B5F),
      DetailStatus.inProgress => const Color(0xFF1B4332),
      DetailStatus.resolved => const Color(0xFFEDEEF2),
    };
  }

  Color get activeIconColor {
    return switch (this) {
      DetailStatus.submitted => Colors.white,
      DetailStatus.underReview => Colors.white,
      DetailStatus.inProgress => const Color(0xFF52B788),
      DetailStatus.resolved => const Color(0xFFB0BEC5),
    };
  }

  IconData get icon {
    return switch (this) {
      DetailStatus.submitted => Icons.check_rounded,
      DetailStatus.underReview => Icons.check_rounded,
      DetailStatus.inProgress => Icons.sync_rounded,
      DetailStatus.resolved => Icons.flag_outlined,
    };
  }
}

class TimelineStep {
  final DetailStatus status;
  final String description;
  final String? dateTime;
  final bool isActive;
  final bool isPast;

  const TimelineStep({
    required this.status,
    required this.description,
    this.dateTime,
    this.isActive = false,
    this.isPast = false,
  });
}

class OfficialResponse {
  final String responderName;
  final String timeAgo;
  final String avatarLabel;
  final String message;

  const OfficialResponse({
    required this.responderName,
    required this.timeAgo,
    required this.avatarLabel,
    required this.message,
  });
}

class DetailAspirasiModel {
  final int reportId;
  final String aspirationId;
  final String category;
  final String dateLabel;
  final String title;
  final DetailStatus currentStatus;
  final String? attachmentImagePath; // null = use placeholder
  final String detailDescription;
  final String locationAddress;
  final double? locationLat;
  final double? locationLong;
  final List<TimelineStep> timeline;
  final OfficialResponse? officialResponse;
  final List<int> evidenceIds;

  const DetailAspirasiModel({
    required this.reportId,
    required this.aspirationId,
    required this.category,
    required this.dateLabel,
    required this.title,
    required this.currentStatus,
    this.attachmentImagePath,
    required this.detailDescription,
    required this.locationAddress,
    this.locationLat,
    this.locationLong,
    required this.timeline,
    this.officialResponse,
    this.evidenceIds = const [],
  });
}
