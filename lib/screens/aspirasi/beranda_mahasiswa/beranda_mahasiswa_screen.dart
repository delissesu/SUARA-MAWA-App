import 'package:flutter/material.dart';
import 'widgets/welcome_header.dart';
import 'widgets/status_cards_section.dart';
import 'widgets/submit_banner.dart';
import 'widgets/recent_activity_section.dart';
import 'widgets/floating_submit_button.dart';
import '../form_aspirasi/form_aspirasi_screen.dart';

class BerandaMahasiswaScreen extends StatelessWidget {
  const BerandaMahasiswaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const WelcomeHeader(studentName: 'Student'),
                  const SizedBox(height: 24),
                  const StatusCardsSection(
                    pendingCount: 3,
                    processedCount: 1,
                    resolvedCount: 12,
                  ),
                  const SizedBox(height: 16),
                  SubmitBanner(
                    onSubmitPressed: () {
                      // TODO: Navigate to submit aspiration screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FormAspirasiScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  RecentActivitySection(
                    onViewAll: () {
                      // TODO: Navigate to history screen
                      RecentActivitySection;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          FloatingSubmitButton(
            onPressed: () {
              // TODO: Navigate to submit aspiration screen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FormAspirasiScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
