import 'package:flutter/material.dart';
import 'package:suara_mawa/utils/app_colors.dart';

class StepProgressView extends StatelessWidget {
  final double width;
  final List<String> titles;
  final int currentStep;
  final Color activeColor;
  static const double lineWidth = 3.0;
  static const double circleSize = 20.0;

  const StepProgressView({
    super.key,
    required this.currentStep,
    required this.titles,
    required this.width,
    required this.activeColor,
  }) : assert(width > 0);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Row(
            children: _buildIcons(),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildTitles(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildIcons() {
    final widgets = <Widget>[];

    for (int i = 0; i < titles.length; i++) {
      final isCompleted = currentStep > i + 1;
      final isCurrent = currentStep == i + 1;

      final color =
          (isCompleted || isCurrent) ? activeColor : AppColors.inactive;

      widgets.add(
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(circleSize),
            border: Border.all(
              color: color,
              width: 2,
            ),
          ),
          child: Icon(
            Icons.circle,
            size: 12,
            color: color,
          ),
        ),
      );

      if (i != titles.length - 1) {
        widgets.add(
          Expanded(
            child: Container(
              height: lineWidth,
              color: isCompleted
                  ? activeColor
                  : AppColors.inactive,
            ),
          ),
        );
      }
    }

    return widgets;
  }

  List<Widget> _buildTitles() {
    return titles
        .map(
          (title) => Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
            ),
          ),
        )
        .toList();
  }
}