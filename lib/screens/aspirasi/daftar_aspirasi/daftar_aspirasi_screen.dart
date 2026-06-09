import 'package:flutter/material.dart';
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

  AspirasiStatus _selectedStatus = AspirasiStatus.all;
  String _searchQuery = '';
  bool _isLoadingMore = false;

  // Full list — replace with paginated API data from Dio
  final List<AspirasiItem> _allItems = List.from(dummyAspirations);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    setState(() => _isLoadingMore = true);

    // TODO: Replace with paginated API call via Dio
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoadingMore = false);
  }

  void _handleViewDetails(AspirasiItem item) {
    // TODO: Navigate to Detail Aspirasi screen
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (_) => DetailAspirasiScreen(item: item)),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
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
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: AspirasiListSection(
                items: _filteredItems,
                onViewDetails: _handleViewDetails,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            sliver: SliverToBoxAdapter(
              child: LoadMoreButton(
                isLoading: _isLoadingMore,
                onPressed: _handleLoadMore,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
