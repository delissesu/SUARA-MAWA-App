class ReportCategory {
  final int id;
  final String name;

  const ReportCategory({required this.id, required this.name});

  factory ReportCategory.fromJson(Map<String, dynamic> json) {
    return ReportCategory(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class ReportDepartment {
  final int id;
  final String name;

  const ReportDepartment({required this.id, required this.name});

  factory ReportDepartment.fromJson(Map<String, dynamic> json) {
    return ReportDepartment(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

/// A single item returned by `GET /mahasiswa/my-reports` or `GET /report/all`.
class ReportListItem {
  final int id;
  final String title;
  final String description;
  final String? location;
  final int likes;
  final String authorName;
  final String departmentName;
  final String categoriesName;

  /// Only present in filtered endpoint responses.
  final String? latestStatus;
  final String? thumbnail;
  final DateTime? createdAt;

  const ReportListItem({
    required this.id,
    required this.title,
    required this.description,
    this.location,
    required this.likes,
    required this.authorName,
    required this.departmentName,
    required this.categoriesName,
    this.latestStatus,
    this.thumbnail,
    this.createdAt,
  });

  factory ReportListItem.fromJson(Map<String, dynamic> json) {
    return ReportListItem(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String?,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      authorName: json['authorName'] as String? ?? '',
      departmentName: json['departmentName'] as String? ?? '',
      categoriesName: json['categoriesName'] as String? ?? '',
      latestStatus: json['latestStatus'] as String?,
      thumbnail: json['thumbnail'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

/// Pagination metadata returned by paginated endpoints.
class PaginationMeta {
  final int totalRows;
  final int totalPages;
  final int currentPage;
  final int pageSize;

  const PaginationMeta({
    required this.totalRows,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      totalRows: (json['totalRows'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
      pageSize: (json['PAGE_SIZE'] as num?)?.toInt() ?? 10,
    );
  }

  bool get hasMore => currentPage < totalPages;
}

/// Wraps a paginated list response with its metadata.
class PaginatedReports {
  final List<ReportListItem> data;
  final PaginationMeta meta;

  const PaginatedReports({required this.data, required this.meta});

  factory PaginatedReports.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List?)
            ?.map((e) =>
                ReportListItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return PaginatedReports(
      data: dataList,
      meta: PaginationMeta.fromJson(
          json['meta'] as Map<String, dynamic>? ?? {}),
    );
  }
}

// Report Detail

class ReportAuthor {
  final String name;
  final int? photoProfileId;
  final String? urlFotoProfil;

  const ReportAuthor({
    required this.name,
    this.photoProfileId,
    this.urlFotoProfil,
  });

  factory ReportAuthor.fromJson(Map<String, dynamic> json) {
    return ReportAuthor(
      name: json['name'] as String? ?? '',
      photoProfileId: (json['photoProfileId'] as num?)?.toInt(),
      urlFotoProfil: json['url_foto_profil'] as String?,
    );
  }
}

class ReportEvidence {
  final int id;
  final ReportEvidenceFile? file;

  const ReportEvidence({required this.id, this.file});

  factory ReportEvidence.fromJson(Map<String, dynamic> json) {
    return ReportEvidence(
      id: json['id'] as int,
      file: json['file'] != null
          ? ReportEvidenceFile.fromJson(json['file'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ReportEvidenceFile {
  final int id;
  final String name;
  final String filetype;

  const ReportEvidenceFile({
    required this.id,
    required this.name,
    required this.filetype,
  });

  factory ReportEvidenceFile.fromJson(Map<String, dynamic> json) {
    return ReportEvidenceFile(
      id: json['id'] as int,
      name: json['name'] as String,
      filetype: json['filetype'] as String,
    );
  }
}

class ReportStatusItem {
  final int id;
  final String status;
  final DateTime? createdAt;
  final ReportStatusAuthor? author;

  const ReportStatusItem({
    required this.id,
    required this.status,
    this.createdAt,
    this.author,
  });

  factory ReportStatusItem.fromJson(Map<String, dynamic> json) {
    return ReportStatusItem(
      id: json['id'] as int,
      status: json['status'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      author: json['author'] != null
          ? ReportStatusAuthor.fromJson(json['author'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ReportStatusAuthor {
  final String id;
  final String name;

  const ReportStatusAuthor({required this.id, required this.name});

  factory ReportStatusAuthor.fromJson(Map<String, dynamic> json) {
    return ReportStatusAuthor(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
    );
  }
}

/// Full report detail as returned by `POST /report/detail`.
class ReportDetail {
  final int id;
  final String title;
  final String description;
  final double locationLat;
  final double locationLong;
  final String? location;
  final bool isPublic;
  final int likes;
  final ReportAuthor author;
  final ReportDetailDepartment department;
  final ReportDetailCategory category;
  final List<ReportEvidence> evidences;
  final List<ReportStatusItem> statuses;
  final DateTime? reportDate;

  const ReportDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.locationLat,
    required this.locationLong,
    this.location,
    required this.isPublic,
    required this.likes,
    required this.author,
    required this.department,
    required this.category,
    required this.evidences,
    required this.statuses,
    this.reportDate,
  });

  factory ReportDetail.fromJson(Map<String, dynamic> json) {
    return ReportDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      locationLat: (json['locationLat'] as num).toDouble(),
      locationLong: (json['locationLong'] as num).toDouble(),
      location: json['location'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      author: ReportAuthor.fromJson(
          json['author'] as Map<String, dynamic>? ?? {}),
      department: ReportDetailDepartment.fromJson(
          json['department'] as Map<String, dynamic>? ?? {}),
      category: ReportDetailCategory.fromJson(
          json['category'] as Map<String, dynamic>? ?? {}),
      evidences: (json['reportEvidences'] as List?)
              ?.map((e) =>
                  ReportEvidence.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      statuses: (json['reportStatus'] as List?)
              ?.map((e) =>
                  ReportStatusItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      reportDate: json['report_date'] != null
          ? DateTime.tryParse(json['report_date'].toString())
          : null,
    );
  }

  /// Returns the latest status string (e.g. "pending", "in_progress", "resolved").
  String get latestStatus {
    if (statuses.isEmpty) return 'pending';
    // Statuses are pre-sorted by the backend; last one is latest.
    return statuses.last.status;
  }
}

class ReportDetailDepartment {
  final String name;

  const ReportDetailDepartment({required this.name});

  factory ReportDetailDepartment.fromJson(Map<String, dynamic> json) {
    return ReportDetailDepartment(name: json['name'] as String? ?? '');
  }
}

class ReportDetailCategory {
  final String name;

  const ReportDetailCategory({required this.name});

  factory ReportDetailCategory.fromJson(Map<String, dynamic> json) {
    return ReportDetailCategory(name: json['name'] as String? ?? '');
  }
}

// Feedback

class ReportFeedback {
  final int id;
  final String status;
  final DateTime? changedAt;
  final FeedbackDetail? feedback;
  final ReportStatusAuthor? changedBy;

  const ReportFeedback({
    required this.id,
    required this.status,
    this.changedAt,
    this.feedback,
    this.changedBy,
  });

  factory ReportFeedback.fromJson(Map<String, dynamic> json) {
    return ReportFeedback(
      id: json['id'] as int,
      status: json['status'] as String,
      changedAt: json['changedAt'] != null
          ? DateTime.tryParse(json['changedAt'].toString())
          : null,
      feedback: json['feedback'] != null
          ? FeedbackDetail.fromJson(json['feedback'] as Map<String, dynamic>)
          : null,
      changedBy: json['changedById'] != null
          ? ReportStatusAuthor.fromJson(
              json['changedById'] as Map<String, dynamic>)
          : null,
    );
  }
}

class FeedbackDetail {
  final int id;
  final String description;
  final List<FeedbackAttachment> attachments;

  const FeedbackDetail({
    required this.id,
    required this.description,
    required this.attachments,
  });

  factory FeedbackDetail.fromJson(Map<String, dynamic> json) {
    return FeedbackDetail(
      id: json['id'] as int,
      description: json['description'] as String? ?? '',
      attachments: (json['feedbackAttachments'] as List?)
              ?.map((e) =>
                  FeedbackAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class FeedbackAttachment {
  final int id;
  final FeedbackAttachmentFile? file;

  const FeedbackAttachment({required this.id, this.file});

  factory FeedbackAttachment.fromJson(Map<String, dynamic> json) {
    return FeedbackAttachment(
      id: json['id'] as int,
      file: json['file'] != null
          ? FeedbackAttachmentFile.fromJson(
              json['file'] as Map<String, dynamic>)
          : null,
    );
  }
}

class FeedbackAttachmentFile {
  final int id;
  final String name;
  final String filetype;

  const FeedbackAttachmentFile({
    required this.id,
    required this.name,
    required this.filetype,
  });

  factory FeedbackAttachmentFile.fromJson(Map<String, dynamic> json) {
    return FeedbackAttachmentFile(
      id: json['id'] as int,
      name: json['name'] as String,
      filetype: json['filetype'] as String,
    );
  }
}
