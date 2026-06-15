import 'package:flutter/material.dart';
import '../models/detail_aspirasi_model.dart';
import '../components/info_section_card.dart';
import '../components/timeline_step_item.dart';

class ResolutionTimelineCard extends StatelessWidget {
  final List<TimelineStep> timeline;

  const ResolutionTimelineCard({super.key, required this.timeline});

  @override
  Widget build(BuildContext context) {
    return InfoSectionCard(
      icon: Icons.history_toggle_off_rounded,
      title: 'Linimasa Penyelesaian',
      child: Column(
        children: List.generate(timeline.length, (index) {
          return TimelineStepItem(
            step: timeline[index],
            isLast: index == timeline.length - 1,
          );
        }),
      ),
    );
  }
}
