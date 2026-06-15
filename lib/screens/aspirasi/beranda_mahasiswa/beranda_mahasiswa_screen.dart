import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/aspirasi/models/report_model.dart';
import 'package:suara_mawa/screens/aspirasi/services/report_service.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';
import 'package:suara_mawa/utils/user_controller.dart';
import 'widgets/welcome_header.dart';
import 'widgets/status_cards_section.dart';
import 'widgets/submit_banner.dart';
import 'widgets/recent_activity_section.dart';
import '../form_aspirasi/form_aspirasi_screen.dart';
import '../daftar_aspirasi/daftar_aspirasi_screen.dart';

class BerandaMahasiswaScreen extends StatefulWidget {
  const BerandaMahasiswaScreen({super.key});

  @override
  State<BerandaMahasiswaScreen> createState() => _BerandaMahasiswaScreenState();
}

class _BerandaMahasiswaScreenState extends State<BerandaMahasiswaScreen> {
  final AuthService _authService = AuthService();
  final ReportService _reportService = ReportService();

  String _studentName = 'Student';
  int _pendingCount = 0;
  int _processedCount = 0;
  int _resolvedCount = 0;
  List<ReportListItem> _recentItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Fetch user data and reports concurrently
      final results = await Future.wait([
        _authService.getUser(),
        _reportService.getMyReports(currentPage: 1),
      ]);

      final user = results[0] as User?;
      final reports = results[1] as List<ReportListItem>;

      if (!mounted) return;

      // Count statuses from the first page of reports.
      // Note: the my-reports endpoint does not return latestStatus,
      // so we show aggregate counts from what we have.
      // For a more accurate count, we'd need a dedicated summary endpoint.
      // For now, we display the total items loaded.
      int pending = 0;
      int processed = 0;
      int resolved = 0;

      for (final report in reports) {
        final status = report.latestStatus?.toLowerCase() ?? 'pending';
        if (status == 'pending' || status == 'revision') {
          pending++;
        } else if (status == 'in_progress') {
          processed++;
        } else if (status == 'resolved' || status == 'rejected') {
          resolved++;
        } else {
          pending++;
        }
      }

      setState(() {
        _studentName = user?.name ?? 'Student';
        _recentItems = reports.take(3).toList();
        _pendingCount = pending;
        _processedCount = processed;
        _resolvedCount = resolved;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                WelcomeHeader(studentName: _studentName),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatusCardsSection(
                            pendingCount: _pendingCount,
                            processedCount: _processedCount,
                            resolvedCount: _resolvedCount,
                          ),
                          const SizedBox(height: 16),
                          SubmitBanner(
                            onSubmitPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const FormAspirasiScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 28),
                          RecentActivitySection(
                            recentItems: _recentItems,
                            isLoading: _isLoading,
                            onViewAll: () {
                              // Navigate to History tab (index 1)
                              // via parent SharedMainScreen
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const DaftarAspirasiScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
