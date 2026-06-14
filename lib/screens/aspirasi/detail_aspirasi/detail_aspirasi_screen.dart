import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:suara_mawa/screens/aspirasi/models/report_model.dart';
import 'package:suara_mawa/screens/aspirasi/services/report_service.dart';
import 'models/detail_aspirasi_model.dart';
import 'widgets/detail_app_bar.dart';
import 'widgets/detail_header_section.dart';
import 'widgets/attachment_image_section.dart';
import 'widgets/aspiration_detail_card.dart';
import 'widgets/reported_location_card.dart';
import 'widgets/resolution_timeline_card.dart';
import 'widgets/official_response_card.dart';

class DetailAspirasiScreen extends StatefulWidget {
  /// The report ID to fetch from the API.
  final int reportId;

  const DetailAspirasiScreen({super.key, required this.reportId});

  @override
  State<DetailAspirasiScreen> createState() => _DetailAspirasiScreenState();
}

class _DetailAspirasiScreenState extends State<DetailAspirasiScreen> {
  final ReportService _reportService = ReportService();

  DetailAspirasiModel? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  String _timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(dateTime);
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final detail = await _reportService.getReportDetail(widget.reportId);

      if (!mounted) return;

      if (detail == null) {
        setState(() {
          _error = 'Report not found';
          _isLoading = false;
        });
        return;
      }

      // Fetch official response/feedback if the report has status updates other than pending
      OfficialResponse? officialResponse;
      final nonPendingStatuses = detail.statuses
          .where((s) => s.status.toLowerCase() != 'pending')
          .toList();
      if (nonPendingStatuses.isNotEmpty) {
        // Fetch feedback for the latest non-pending status
        final latestStatus = nonPendingStatuses.last;
        try {
          final feedbacks = await _reportService.getFeedbackDetail(latestStatus.id);
          if (feedbacks.isNotEmpty) {
            final fb = feedbacks.first;
            if (fb.feedback != null) {
              officialResponse = OfficialResponse(
                responderName: fb.changedBy?.name ?? latestStatus.author?.name ?? 'Official Responder',
                timeAgo: fb.changedAt != null ? _timeAgo(fb.changedAt!) : '',
                avatarLabel: (fb.changedBy?.name ?? latestStatus.author?.name ?? 'O')[0].toUpperCase(),
                message: fb.feedback!.description,
              );
            }
          }
        } catch (_) {}
      }

      // Map API ReportDetail → UI DetailAspirasiModel
      final model = _mapToDetailModel(detail, officialResponse);

      setState(() {
        _data = model;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load report details';
        _isLoading = false;
      });
    }
  }

  DetailAspirasiModel _mapToDetailModel(ReportDetail detail, OfficialResponse? officialResponse) {
    // Build timeline from statuses
    final timeline = <TimelineStep>[];
    for (int i = 0; i < detail.statuses.length; i++) {
      final status = detail.statuses[i];
      final isLast = i == detail.statuses.length - 1;
      timeline.add(TimelineStep(
        status: DetailStatus.fromApiStatus(status.status),
        description: _statusDescription(status),
        dateTime: status.createdAt != null
            ? _formatDateTime(status.createdAt!)
            : null,
        isActive: isLast,
        isPast: !isLast,
      ));
    }

    // Find the first image evidence for the header attachment
    String? attachmentUrl;
    final imageEvidences = detail.evidences
        .where((e) => e.file?.filetype == 'image')
        .toList();
    if (imageEvidences.isNotEmpty) {
      attachmentUrl =
          _reportService.evidencePreviewUrl(imageEvidences.first.id);
    }

    return DetailAspirasiModel(
      aspirationId: 'RPT-${detail.id.toString().padLeft(3, '0')}',
      category: detail.category.name,
      dateLabel: detail.reportDate != null
          ? _formatDate(detail.reportDate!)
          : '',
      title: detail.title,
      currentStatus: DetailStatus.fromApiStatus(detail.latestStatus),
      attachmentImagePath: attachmentUrl,
      detailDescription: detail.description,
      locationAddress: detail.location ?? 'No location detail provided',
      locationLat: detail.locationLat,
      locationLong: detail.locationLong,
      timeline: timeline,
      officialResponse: officialResponse,
      evidenceIds: detail.evidences.map((e) => e.id).toList(),
    );
  }

  String _statusDescription(ReportStatusItem status) {
    final authorName = status.author?.name ?? 'System';
    return switch (status.status.toLowerCase()) {
      'pending' => 'Report submitted and awaiting review.',
      'in_progress' => 'Being processed by $authorName.',
      'resolved' => 'Resolved by $authorName.',
      'revision' => 'Revision requested by $authorName.',
      'rejected' => 'Rejected by $authorName.',
      _ => 'Status updated by $authorName.',
    };
  }

  String _formatDateTime(DateTime dt) {
    try {
      return DateFormat('MMM d, yyyy · hh:mm a').format(dt);
    } catch (_) {
      return dt.toIso8601String();
    }
  }

  String _formatDate(DateTime dt) {
    try {
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {
      return dt.toIso8601String();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        appBar: const DetailAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _data == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF0F2F5),
        appBar: const DetailAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                _error ?? 'Something went wrong',
                style: TextStyle(
                  fontFamily: 'PublicSans',
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _fetchDetail,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final data = _data!;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: const DetailAppBar(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header: category, ID, title, status ──────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(child: DetailHeaderSection(item: data)),
          ),

          // ── Attachment photo ─────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: AttachmentImageSection(imageUrl: data.attachmentImagePath),
            ),
          ),

          // ── Aspiration details ────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: AspirationDetailCard(description: data.detailDescription),
            ),
          ),

          // ── Reported location ─────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: ReportedLocationCard(
                address: data.locationAddress,
                coordinates: (data.locationLat != null && data.locationLong != null)
                    ? LatLng(data.locationLat!, data.locationLong!)
                    : null,
              ),
            ),
          ),

          // ── Resolution timeline ───────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: ResolutionTimelineCard(timeline: data.timeline),
            ),
          ),

          // ── Official response ─────────────────────────────────────────
          if (data.officialResponse != null)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: OfficialResponseCard(response: data.officialResponse!),
              ),
            ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }
}
