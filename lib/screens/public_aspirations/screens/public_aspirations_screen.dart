import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suara_mawa/screens/public_aspirations/models/public_report.dart';
import 'package:suara_mawa/screens/public_aspirations/services/public_aspiration_service.dart';
import 'package:suara_mawa/screens/public_aspirations/screens/public_aspiration_detail_screen.dart';
import 'package:suara_mawa/utils/app_colors.dart';
import 'package:suara_mawa/utils/user_controller.dart';
import 'package:intl/intl.dart';

class PublicAspirationsScreen extends ConsumerStatefulWidget {
  const PublicAspirationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PublicAspirationsScreen> createState() => _PublicAspirationsScreenState();
}

class _PublicAspirationsScreenState extends ConsumerState<PublicAspirationsScreen> {
  final PublicAspirationService _service = PublicAspirationService();
  List<PublicReport> _reports = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMoreData = true;
  String? _error;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchReports();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _fetchMoreReports();
    }
  }

  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _reports.clear();
      _hasMoreData = true;
      _error = null;
    });

    try {
      final reports = await _service.getPublicAspirations(page: _currentPage, pageSize: _pageSize);
      
      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoading = false;
          if (reports.length < _pageSize) {
            _hasMoreData = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _fetchMoreReports() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    _currentPage++;
    final reports = await _service.getPublicAspirations(page: _currentPage, pageSize: _pageSize);

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
        if (reports.isEmpty) {
          _hasMoreData = false;
        } else {
          _reports.addAll(reports);
          if (reports.length < _pageSize) {
            _hasMoreData = false;
          }
        }
      });
    }
  }

  Future<void> _likeReport(int index) async {
    final report = _reports[index];
    final success = await _service.likeAspiration(report.id);
    if (success) {
      setState(() {
        int currentLikes = int.tryParse(report.likes) ?? 0;
        bool newIsLiked = !report.isLiked;
        int newLikes = newIsLiked ? currentLikes + 1 : currentLikes - 1;
        if (newLikes < 0) newLikes = 0;

        _reports[index] = PublicReport(
          id: report.id,
          title: report.title,
          description: report.description,
          location: report.location,
          likes: newLikes.toString(),
          authorName: report.authorName,
          departmentName: report.departmentName,
          categoriesName: report.categoriesName,
          latestStatus: report.latestStatus,
          thumbnail: report.thumbnail,
          createdAt: report.createdAt,
          isLiked: newIsLiked,
        );
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _fetchReports,
        color: AppColors.primary,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _error != null
                ? ListView(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Error: $_error",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  )
                : _reports.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                          const Center(
                            child: Text(
                              "Belum ada aspirasi publik.",
                              style: TextStyle(color: AppColors.subtext1, fontSize: 16),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _reports.length + (_hasMoreData ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _reports.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: CircularProgressIndicator(color: AppColors.primary),
                              ),
                            );
                          }

                          final report = _reports[index];
                          return _buildReportCard(report, index);
                        },
                      ),
      ),
    );
  }

  Widget _buildReportCard(PublicReport report, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PublicAspirationDetailScreen(reportId: report.id),
              ),
            ).then((_) => _fetchReports()); // Refresh when coming back
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.activePrimary,
                          child: Text(
                            report.authorName.isNotEmpty ? report.authorName[0].toUpperCase() : '?',
                            style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          report.authorName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ],
                    ),
                    if (report.createdAt != null)
                      Text(
                        _formatDate(report.createdAt),
                        style: const TextStyle(color: AppColors.subtext1, fontSize: 12),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  report.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  report.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: AppColors.subtext1),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.activePrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        report.categoriesName,
                        style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (report.latestStatus != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(report.latestStatus!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          report.latestStatus!.toUpperCase(),
                          style: TextStyle(color: _getStatusColor(report.latestStatus!), fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.inactive),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            report.isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined, 
                            color: AppColors.primary, 
                            size: 20
                          ),
                          onPressed: () => _likeReport(index),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                        Text(
                          report.likes,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.comment_outlined, color: AppColors.primary, size: 20),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PublicAspirationDetailScreen(reportId: report.id),
                              ),
                            ).then((_) => _fetchReports());
                          },
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                      ],
                    ),
                    const Text(
                      "Lihat Detail",
                      style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
