import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final bool isWide;

  const StatusCard({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: isWide ? _buildWideLayout() : _buildCompactLayout(),
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: iconColor, size: 22),
            Text(
              '$count',
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.w800,
                fontSize: 28,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'PublicSans',
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: textColor,
              ),
            ),
          ],
        ),
        Text(
          '$count',
          style: TextStyle(
            fontFamily: 'PublicSans',
            fontWeight: FontWeight.w800,
            fontSize: 32,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
