import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suara_mawa/screens/public_aspirations/models/comment.dart';
import 'package:suara_mawa/screens/public_aspirations/services/public_aspiration_service.dart';
import 'package:suara_mawa/screens/penindak/services/report_service.dart';
import 'package:suara_mawa/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PublicAspirationDetailScreen extends ConsumerStatefulWidget {
  final int reportId;
  const PublicAspirationDetailScreen({Key? key, required this.reportId}) : super(key: key);

  @override
  ConsumerState<PublicAspirationDetailScreen> createState() => _PublicAspirationDetailScreenState();
}

class _PublicAspirationDetailScreenState extends ConsumerState<PublicAspirationDetailScreen> {
  final ReportService _reportService = ReportService();
  final PublicAspirationService _publicService = PublicAspirationService();
  
  Map<String, dynamic>? _data;
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isLiking = false;
  bool _isCommenting = false;
  String? _error;
  
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final result = await _reportService.fetchReportDetail(widget.reportId);
      final comments = await _publicService.getComments(widget.reportId);
      
      if (mounted) {
        setState(() {
          _data = result;
          _comments = comments;
          _isLoading = false;
          if (result == null) _error = 'Gagal memuat detail laporan.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Terjadi kesalahan saat memuat data.';
        });
      }
    }
  }

  Future<void> _likeReport() async {
    if (_isLiking || _data == null) return;
    
    setState(() {
      _isLiking = true;
    });
    
    final success = await _publicService.likeAspiration(widget.reportId);
    
    if (success && mounted) {
      setState(() {
        bool currentIsLiked = _data!['isLiked'] ?? _data!['is_liked'] ?? false;
        int currentLikes = int.tryParse(_data!['likes']?.toString() ?? '0') ?? 0;
        
        bool newIsLiked = !currentIsLiked;
        int newLikes = newIsLiked ? currentLikes + 1 : currentLikes - 1;
        if (newLikes < 0) newLikes = 0;
        
        _data!['isLiked'] = newIsLiked;
        _data!['likes'] = newLikes.toString();
      });
    }
    
    if (mounted) {
      setState(() {
        _isLiking = false;
      });
    }
  }

  Future<void> _addComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty || _isCommenting) return;
    
    setState(() {
      _isCommenting = true;
    });
    
    final success = await _publicService.addComment(widget.reportId, commentText);
    
    if (success && mounted) {
      _commentController.clear();
      // Refresh comments
      final comments = await _publicService.getComments(widget.reportId);
      setState(() {
        _comments = comments;
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menambahkan komentar')),
      );
    }
    
    if (mounted) {
      setState(() {
        _isCommenting = false;
      });
    }
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (_) {
      return isoString;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'revision':
        return Colors.orange;
      case 'resolved':
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Aspirasi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null || _data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Terjadi kesalahan.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    final report = _data!;
    final statusList = (report['reportStatus'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final latestStatus = statusList.isNotEmpty ? statusList.last['status'] as String : 'pending';
    final likes = report['likes']?.toString() ?? '0';
    final isLiked = report['isLiked'] ?? report['is_liked'] ?? false;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        report['title'] ?? '',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(latestStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        latestStatus.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(latestStatus),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Author & Date
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.activePrimary,
                      child: Text(
                        (report['author']?['name'] ?? '?')[0].toUpperCase(),
                        style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report['author']?['name'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            _formatDate(report['report_date']),
                            style: const TextStyle(color: AppColors.subtext1, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Description
                const Text(
                  'Deskripsi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  report['description'] ?? '',
                  style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                ),
                const SizedBox(height: 20),

                // Location
                if (report['location'] != null) ...[
                  const Text(
                    'Lokasi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          report['location'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Map if coordinates exist
                if (report['latitude'] != null && report['longitude'] != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 150,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(
                            double.parse(report['latitude'].toString()),
                            double.parse(report['longitude'].toString()),
                          ),
                          initialZoom: 15.0,
                          interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.suara.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(
                                  double.parse(report['latitude'].toString()),
                                  double.parse(report['longitude'].toString()),
                                ),
                                width: 40,
                                height: 40,
                                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Likes & Comments Count
                Row(
                  children: [
                    InkWell(
                      onTap: _likeReport,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.activePrimary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            _isLiking 
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                              : Icon(
                                  isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined, 
                                  color: AppColors.primary, 
                                  size: 18
                                ),
                            const SizedBox(width: 6),
                            Text(
                              likes,
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.comment_outlined, color: Colors.grey, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${_comments.length} Komentar',
                            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),

                // Comments Section
                const Text(
                  'Komentar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                if (_comments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Belum ada komentar. Jadilah yang pertama!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _comments.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.activePrimary,
                            child: Text(
                              (comment.user?.name.isNotEmpty == true) ? comment.user!.name[0].toUpperCase() : '?',
                              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        comment.user?.name ?? 'Unknown',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      Text(
                                        _formatDate(comment.createdAt),
                                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment.comment,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        
        // Comment Input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, -2),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Tulis komentar...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _addComment(),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: _isCommenting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: _addComment,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
