import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/aspirasi/models/report_model.dart';
import 'package:suara_mawa/screens/aspirasi/services/report_service.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';
import 'package:suara_mawa/utils/page_transitions.dart';
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

class _BerandaMahasiswaScreenState extends State<BerandaMahasiswaScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final ReportService _reportService = ReportService();

  String _studentName = 'Student';
  int _pendingCount = 0;
  int _processedCount = 0;
  int _resolvedCount = 0;
  List<ReportListItem> _recentItems = [];
  bool _isLoading = true;

  // Staggered entrance animation
  late AnimationController _entranceController;
  late Animation<double> _welcomeFade;
  late Animation<Offset> _welcomeSlide;
  late Animation<double> _statusFade;
  late Animation<Offset> _statusSlide;
  late Animation<double> _bannerFade;
  late Animation<Offset> _bannerSlide;
  late Animation<double> _activityFade;
  late Animation<Offset> _activitySlide;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    // Welcome header: 0.0 → 0.35
    _welcomeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _welcomeSlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOutCubic),
      ),
    );

    // Status cards: 0.15 → 0.55
    _statusFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOut),
      ),
    );
    _statusSlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.55, curve: Curves.easeOutCubic),
      ),
    );

    // Submit banner: 0.35 → 0.75
    _bannerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOut),
      ),
    );
    _bannerSlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    // Recent activity: 0.50 → 1.0
    _activityFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.50, 1.0, curve: Curves.easeOut),
      ),
    );
    _activitySlide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.50, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _loadData();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
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

      // Play staggered entrance after data loads
      _entranceController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _entranceController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: RefreshIndicator(
        onRefresh: () async {
          _entranceController.reset();
          await _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // Animated welcome header
                FadeTransition(
                  opacity: _welcomeFade,
                  child: SlideTransition(
                    position: _welcomeSlide,
                    child: WelcomeHeader(studentName: _studentName),
                  ),
                ),
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
                          // Animated status cards
                          FadeTransition(
                            opacity: _statusFade,
                            child: SlideTransition(
                              position: _statusSlide,
                              child: StatusCardsSection(
                                pendingCount: _pendingCount,
                                processedCount: _processedCount,
                                resolvedCount: _resolvedCount,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Animated submit banner
                          FadeTransition(
                            opacity: _bannerFade,
                            child: SlideTransition(
                              position: _bannerSlide,
                              child: SubmitBanner(
                                onSubmitPressed: () {
                                  Navigator.of(context).push(
                                    slidePageRoute(
                                      const FormAspirasiScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Animated recent activity
                          FadeTransition(
                            opacity: _activityFade,
                            child: SlideTransition(
                              position: _activitySlide,
                              child: RecentActivitySection(
                                recentItems: _recentItems,
                                isLoading: _isLoading,
                                onViewAll: () {
                                  // Navigate to History tab (index 1)
                                  // via parent SharedMainScreen
                                  Navigator.of(context).push(
                                    slidePageRoute(
                                      const DaftarAspirasiScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
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
