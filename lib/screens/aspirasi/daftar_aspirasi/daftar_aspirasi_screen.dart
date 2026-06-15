import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/aspirasi/models/report_model.dart';
import 'package:suara_mawa/screens/aspirasi/services/report_service.dart';
import 'package:suara_mawa/screens/aspirasi/detail_aspirasi/detail_aspirasi_screen.dart';
import 'package:suara_mawa/utils/page_transitions.dart';
import '../beranda_mahasiswa/widgets/floating_submit_button.dart';
import '../form_aspirasi/form_aspirasi_screen.dart';
import 'models/aspirasi_item.dart';
import 'widgets/history_page_header.dart';
import 'widgets/search_bar_field.dart';
import 'widgets/status_filter_chips.dart';
import 'widgets/aspirasi_list_section.dart';
import 'widgets/load_more_button.dart';

class DaftarAspirasiScreen extends StatefulWidget {
  const DaftarAspirasiScreen({super.key});

  @override
  State<DaftarAspirasiScreen> createState() => _DaftarAspirasiScreenState();
}

class _DaftarAspirasiScreenState extends State<DaftarAspirasiScreen> {
  final _searchController = TextEditingController();
  final ReportService _reportService = ReportService();

  AspirasiStatus _selectedStatus = AspirasiStatus.all;
  String _searchQuery = '';
  bool _isLoadingMore = false;
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;

  /// All loaded report items from the API (across all pages).
  final List<AspirasiItem> _allItems = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Converts a [ReportListItem] from the API into an [AspirasiItem] for UI.
  AspirasiItem _toAspirasiItem(ReportListItem report) {
    return AspirasiItem(
      reportId: report.id,
      id: 'RPT-${report.id.toString().padLeft(3, '0')}',
      title: report.title,
      description: report.description,
      category: report.categoriesName,
      dateLabel: report.createdAt != null
          ? _formatDate(report.createdAt!)
          : report.departmentName,
      status: AspirasiStatus.fromApiStatus(report.latestStatus),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _allItems.clear();
    });

    try {
      final reports = await _reportService.getMyReports(currentPage: 1);
      if (!mounted) return;

      setState(() {
        _allItems.addAll(reports.map(_toAspirasiItem));
        // Backend PAGE_SIZE is 10. If we got fewer, there's no more data.
        _hasMore = reports.length >= 10;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<AspirasiItem> get _filteredItems {
    return _allItems.where((item) {
      final matchesStatus =
          _selectedStatus == AspirasiStatus.all ||
          item.status == _selectedStatus;

      final query = _searchQuery.toLowerCase().trim();
      final matchesSearch =
          query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.id.toLowerCase().contains(query);

      return matchesStatus && matchesSearch;
    }).toList();
  }

  Future<void> _handleLoadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final reports = await _reportService.getMyReports(currentPage: nextPage);

      if (!mounted) return;
      setState(() {
        _allItems.addAll(reports.map(_toAspirasiItem));
        _currentPage = nextPage;
        _hasMore = reports.length >= 10;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  void _handleViewDetails(AspirasiItem item) {
    Navigator.of(context).push(
      slidePageRoute(
        DetailAspirasiScreen(reportId: item.reportId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadInitialData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HistoryPageHeader(),
                        const SizedBox(height: 20),
                        SearchBarField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _searchQuery = value),
                        ),
                        const SizedBox(height: 16),
                        StatusFilterChips(
                          selectedStatus: _selectedStatus,
                          onStatusChanged: (status) =>
                              setState(() => _selectedStatus = status),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                if (_isLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, _hasMore ? 0 : 100),
                    sliver: SliverToBoxAdapter(
                      child: AspirasiListSection(
                        items: _filteredItems,
                        onViewDetails: _handleViewDetails,
                      ),
                    ),
                  ),
                  if (_hasMore)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                      sliver: SliverToBoxAdapter(
                        child: LoadMoreButton(
                          isLoading: _isLoadingMore,
                          onPressed: _handleLoadMore,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          FloatingSubmitButton(
            onPressed: () {
              Navigator.of(context).push(
                slidePageRoute(const FormAspirasiScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
