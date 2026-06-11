import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:suara_mawa/utils/app_colors.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:suara_mawa/screens/penindak/services/report_service.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class TaskDetailScreen extends StatefulWidget {
  final int reportId;
  const TaskDetailScreen({super.key, required this.reportId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final ReportService _service = ReportService();

  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await _service.fetchReportDetail(widget.reportId);
    if (mounted) {
      setState(() {
        _data = result;
        _isLoading = false;
        if (result == null) _error = 'Gagal memuat detail laporan.';
      });
    }
  }

  // ──────────────── HELPERS ────────────────

  String _translateStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'in_progress':
        return 'Diproses';
      case 'revision':
        return 'Perlu Revisi';
      case 'resolved':
        return 'Selesai';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.grey;
      case 'in_progress':
        return Colors.blue;
      case 'revision':
        return Colors.orange;
      case 'resolved':
      case 'completed':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString).toLocal();
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} "
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return isoString;
    }
  }

  // ──────────────── EVIDENCE ACTIONS ────────────────

  void _onEvidenceTap(Map<String, dynamic> evidence, {bool isFeedback = false}) {
    final fileInfo = evidence['file'] as Map<String, dynamic>;
    final filetype = fileInfo['filetype'] as String;
    final evidenceId = evidence['id'] as int;

    switch (filetype) {
      case 'image':
        _showImagePopup(evidenceId, isFeedback: isFeedback);
        break;
      case 'document':
        _previewDocument(evidenceId, isFeedback: isFeedback);
        break;
      case 'video':
        _showVideoPopup(evidenceId, isFeedback: isFeedback);
        break;
    }
  }

  void _showImagePopup(int evidenceId, {bool isFeedback = false}) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder<Uint8List?>(
              future: isFeedback 
                  ? _service.fetchFeedbackAttachmentPreviewBytes(evidenceId) 
                  : _service.fetchEvidencePreviewBytes(evidenceId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return InteractiveViewer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                }
                return const Icon(Icons.broken_image, color: Colors.white, size: 80);
              },
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _previewDocument(int evidenceId, {bool isFeedback = false}) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => _PdfViewerDialog(
        evidenceId: evidenceId,
        service: _service,
        isFeedback: isFeedback,
      ),
    );
  }

  void _showVideoPopup(int evidenceId, {bool isFeedback = false}) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => _VideoPlayerDialog(
        videoUrl: isFeedback 
            ? _service.getFeedbackAttachmentPreviewUrl(evidenceId) 
            : _service.getEvidencePreviewUrl(evidenceId),
        evidenceId: evidenceId,
        service: _service,
      ),
    );
  }

  // ──────────────── STATUS DETAIL ────────────────

  void _onStatusTap(Map<String, dynamic> statusItem) async {
    final statusId = statusItem['id'] as int;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    final feedbackList = await _service.fetchFeedbackDetail(statusId);

    if (!mounted) return;
    Navigator.pop(context); // close loading

    if (feedbackList == null || feedbackList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada catatan untuk status ini.')),
      );
      return;
    }

    final detail = feedbackList.first as Map<String, dynamic>;
    _showFeedbackDialog(detail);
  }

  void _showFeedbackDialog(Map<String, dynamic> detail) {
    final feedback = detail['feedback'] as Map<String, dynamic>?;
    final status = detail['status'] as String? ?? '';
    final changedAt = detail['changedAt'] as String? ?? '';
    final changedBy = detail['changedById'] as Map<String, dynamic>?;
    final statusColor = _getStatusColor(status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Status badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _translateStatus(status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(changedAt),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
              if (changedBy != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Oleh: ${changedBy['name'] ?? ''}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
              const SizedBox(height: 16),

              // Feedback
              if (feedback != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.orange),
                          SizedBox(width: 6),
                          Text(
                            'Catatan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        feedback['description'] ?? '',
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
                // Feedback attachments
                if (feedback['feedbackAttachments'] != null &&
                    (feedback['feedbackAttachments'] as List).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Lampiran',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  _buildEvidenceList(
                    (feedback['feedbackAttachments'] as List).cast<Map<String, dynamic>>(),
                    isFeedback: true,
                  ),
                ],
              ] else ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Tidak ada catatan untuk status ini.',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────── BUILD ────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Laporan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _buildBody(),
      bottomSheet: _shouldShowBottomAction() ? _buildBottomAction() : null,
    );
  }

  bool _shouldShowBottomAction() {
    if (_data == null) return false;
    final statusList = (_data!['reportStatus'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (statusList.isEmpty) return true;
    
    final latestStatus = statusList.last['status'] as String?;
    return latestStatus != 'resolved' && latestStatus != 'completed';
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null || _data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Terjadi kesalahan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadDetail,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final data = _data!;

    return RefreshIndicator(
      onRefresh: _loadDetail,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Main info section ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(data),
                  const SizedBox(height: 16),
                  _buildTitleAndDescription(data),
                  const SizedBox(height: 16),
                  _buildTags(data),
                  if ((data['reportEvidences'] as List?)?.isNotEmpty == true) ...[
                    const SizedBox(height: 20),
                    _buildEvidenceSection(data),
                  ],
                  const SizedBox(height: 20),
                  _buildLocation(data),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Status timeline ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Riwayat Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ketuk riwayat untuk melihat catatan',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  _buildTimeline(data),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ──────────────── WIDGETS ────────────────

  Widget _buildHeader(Map<String, dynamic> data) {
    final author = data['author'] as Map<String, dynamic>?;
    final authorName = author?['name'] ?? 'Anonim';
    final photoUrl = author?['url_foto_profil'] as String?;
    final reportDate = data['report_date'] as String?;

    return Row(
      children: [
        // Profile photo
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[200],
          child: photoUrl != null
              ? ClipOval(
                  child: FutureBuilder<Uint8List?>(
                    future: _service.fetchProfilePhotoBytes(photoUrl),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Image.memory(snapshot.data!, fit: BoxFit.cover, width: 40, height: 40);
                      }
                      return const Icon(Icons.person, size: 20, color: Colors.grey);
                    },
                  ),
                )
              : const Icon(Icons.person, size: 20, color: Colors.grey),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              authorName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              reportDate != null ? 'Dilaporkan pada ${_formatDate(reportDate)}' : 'Tanggal tidak tersedia',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleAndDescription(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data['title'] ?? '',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
        ),
        const SizedBox(height: 12),
        Text(
          data['description'] ?? '',
          style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.6),
        ),
      ],
    );
  }

  Widget _buildTags(Map<String, dynamic> data) {
    final category = data['category']?['name'] ?? '-';
    final department = data['department']?['name'] ?? '-';
    return Row(
      children: [
        _buildChip(Icons.category_outlined, category),
        const SizedBox(width: 12),
        _buildChip(Icons.business_outlined, department),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[800], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Evidence section ──

  Widget _buildEvidenceSection(Map<String, dynamic> data) {
    final evidences = (data['reportEvidences'] as List).cast<Map<String, dynamic>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bukti Laporan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        _buildEvidenceList(evidences),
      ],
    );
  }

  Widget _buildEvidenceList(List<Map<String, dynamic>> evidences, {bool isFeedback = false}) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: evidences.length,
        itemBuilder: (context, index) {
          final evidence = evidences[index];
          final fileInfo = evidence['file'] as Map<String, dynamic>;
          final filetype = fileInfo['filetype'] as String;
          final evidenceId = evidence['id'] as int;

          return GestureDetector(
            onTap: () => _onEvidenceTap(evidence, isFeedback: isFeedback),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                color: const Color(0xFFF4F5F7),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildEvidenceCard(filetype, evidenceId, fileInfo, isFeedback: isFeedback),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEvidenceCard(String filetype, int evidenceId, Map<String, dynamic> fileInfo, {bool isFeedback = false}) {
    switch (filetype) {
      case 'image':
        return Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder<Uint8List?>(
              future: isFeedback 
                  ? _service.fetchFeedbackAttachmentPreviewBytes(evidenceId) 
                  : _service.fetchEvidencePreviewBytes(evidenceId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      ),
                    ),
                  );
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return Image.memory(snapshot.data!, fit: BoxFit.cover);
                }
                return Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                );
              },
            ),
            // Tap affordance overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Icon(Icons.zoom_in, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        );

      case 'video':
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.grey[800]),
            const Center(
              child: Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Text(
                    fileInfo['name'] ?? 'Video',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        );

      case 'document':
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.description_outlined, size: 36, color: AppColors.primary),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                fileInfo['name'] ?? 'Dokumen',
                style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            const Text('Ketuk untuk preview', style: TextStyle(fontSize: 9, color: Colors.blue)),
          ],
        );
    }
  }

  // ── Location ──

  Widget _buildLocation(Map<String, dynamic> data) {
    final double? lat = (data['locationLat'] as num?)?.toDouble();
    final double? lng = (data['locationLong'] as num?)?.toDouble();
    if (lat == null || lng == null) return const SizedBox.shrink();

    final String? locationDetail = data['locationDetail'] as String?;
    final bool hasDetail = locationDetail != null && locationDetail.isNotEmpty;
    final mapCenter = LatLng(lat, lng);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Lokasi Kejadian',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: hasDetail
                ? BorderRadius.zero
                : const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: SizedBox(
              height: 250,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: mapCenter,
                  initialZoom: 16.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.suaramawa.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: mapCenter,
                        width: 40,
                        height: 40,
                        alignment: Alignment.topCenter,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (hasDetail)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      locationDetail,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Timeline ──

  Widget _buildTimeline(Map<String, dynamic> data) {
    final statusList = (data['reportStatus'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (statusList.isEmpty) {
      return Center(
        child: Text('Belum ada riwayat status.', style: TextStyle(color: Colors.grey[500])),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: statusList.length,
      itemBuilder: (context, index) {
        final item = statusList[index];
        final isLast = index == statusList.length - 1;
        final statusColor = _getStatusColor(item['status'] ?? '');

        return InkWell(
          onTap: () => _onStatusTap(item),
          borderRadius: BorderRadius.circular(8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline line + dot
                Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(color: statusColor.withOpacity(0.4), blurRadius: 4),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(width: 2, color: Colors.grey[300]),
                      ),
                  ],
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _translateStatus(item['status'] ?? ''),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: statusColor,
                              ),
                            ),
                            Text(
                              _formatDate(item['created_at'] ?? ''),
                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (item['author'] != null)
                          Text(
                            'Oleh: ${item['author']['name'] ?? ''}',
                            style: TextStyle(color: Colors.grey[700], fontSize: 13),
                          ),
                        const SizedBox(height: 6),
                        // Tap hint
                        Row(
                          children: [
                            Icon(Icons.touch_app_outlined, size: 13, color: Colors.blue[300]),
                            const SizedBox(width: 4),
                            Text(
                              'Ketuk untuk lihat catatan',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[300],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Bottom action ──

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => _FeedbackDialog(
                      reportId: widget.reportId,
                      service: _service,
                      onSuccess: () {
                        _loadDetail();
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00005C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                child: const Text(
                  'Tindak Lanjut',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────── VIDEO PLAYER DIALOG ────────────────

class _VideoPlayerDialog extends StatefulWidget {
  final int evidenceId;
  final String videoUrl;
  final ReportService service;

  const _VideoPlayerDialog({
    required this.evidenceId,
    required this.videoUrl,
    required this.service,
  });

  @override
  State<_VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<_VideoPlayerDialog> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      // Build authenticated URL and use network player
      final uri = Uri.parse(widget.videoUrl);
      final token = await widget.service.getToken();
      _controller = VideoPlayerController.networkUrl(
        uri,
        httpHeaders: {
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': '69420',
        },
      );
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isLoading = false);
        _controller!.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Colors.white),
            )
          else if (_hasError)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 50),
                  SizedBox(height: 12),
                  Text('Gagal memuat video.', style: TextStyle(color: Colors.white)),
                ],
              ),
            )
          else if (_controller != null && _controller!.value.isInitialized) ...[
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                    });
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}


class _PdfViewerDialog extends StatefulWidget {
  final int evidenceId;
  final ReportService service;
  final bool isFeedback;

  const _PdfViewerDialog({
    required this.evidenceId,
    required this.service,
    this.isFeedback = false,
  });

  @override
  State<_PdfViewerDialog> createState() => _PdfViewerDialogState();
}

class _PdfViewerDialogState extends State<_PdfViewerDialog> {
  String? _tempFilePath;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final bytes = await (widget.isFeedback
          ? widget.service.fetchFeedbackAttachmentPreviewBytes(widget.evidenceId)
          : widget.service.fetchEvidencePreviewBytes(widget.evidenceId));
      if (bytes == null || bytes.isEmpty) throw Exception('Empty response');

      final dir = await getTemporaryDirectory();
      final prefix = widget.isFeedback ? 'feedback' : 'evidence';
      final file = File('${dir.path}/${prefix}_${widget.evidenceId}.pdf');
      await file.writeAsBytes(bytes);

      if (mounted) {
        setState(() {
          _tempFilePath = file.path;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void dispose() {
    // Clean up temp file
    if (_tempFilePath != null) {
      File(_tempFilePath!).deleteSync();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Preview Dokumen',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 22),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 50, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            const Text(
                              'Gagal memuat dokumen.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : PDFView(
                        filePath: _tempFilePath!,
                        enableSwipe: true,
                        swipeHorizontal: false,
                        autoSpacing: true,
                        pageFling: true,
                        fitPolicy: FitPolicy.BOTH,
                      ),
          ),
        ],
      ),
    );
  }
}

// ──────────────── FEEDBACK DIALOG ────────────────

class _FeedbackDialog extends StatefulWidget {
  final int reportId;
  final ReportService service;
  final VoidCallback onSuccess;

  const _FeedbackDialog({
    required this.reportId,
    required this.service,
    required this.onSuccess,
  });

  @override
  State<_FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends State<_FeedbackDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  
  String _selectedStatus = 'in_progress';
  List<File> _selectedFiles = [];
  List<String> _fileNames = [];
  bool _isLoading = false;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'in_progress', 'label': 'Diproses'},
    {'value': 'revision', 'label': 'Revisi'},
    {'value': 'resolved', 'label': 'Selesai'},
  ];

  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          for (var path in result.paths) {
            if (path != null) {
              _selectedFiles.add(File(path));
              _fileNames.add(path.split('/').last);
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih file: $e')),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _fileNames.removeAt(index);
    });
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await widget.service.createFeedback(
        reportId: widget.reportId,
        status: _selectedStatus,
        description: _descriptionController.text,
        files: _selectedFiles.isEmpty ? null : _selectedFiles,
        names: _fileNames.isEmpty ? null : _fileNames,
      );

      if (mounted) {
        if (result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Berhasil memberikan feedback')),
          );
          Navigator.pop(context);
          widget.onSuccess();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal memberikan feedback')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tindak Lanjut',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Status Dropdown
                const Text(
                  'Status',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  items: _statusOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option['value'],
                      child: Text(option['label']!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedStatus = value);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Deskripsi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Masukkan catatan tindak lanjut...',
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Deskripsi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // File Picker
                const Text(
                  'Lampiran (Opsional)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.attach_file, size: 18),
                  label: const Text('Pilih File'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                
                if (_selectedFiles.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedFiles.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.insert_drive_file, size: 20, color: AppColors.primary),
                          title: Text(
                            _fileNames[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 18, color: Colors.red),
                            onPressed: () => _removeFile(index),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Tindak',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}