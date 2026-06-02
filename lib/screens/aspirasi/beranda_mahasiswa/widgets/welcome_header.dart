import 'package:flutter/material.dart';

class WelcomeHeader extends StatelessWidget {
  final String studentName;

  const WelcomeHeader({super.key, this.studentName = 'Student'});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,\n$studentName',
          style: const TextStyle(
            fontFamily: 'PublicSans',
            fontWeight: FontWeight.w800,
            fontSize: 30,
            height: 1.2,
            color: Color(0xFF0D1B2A),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Here's a summary of your recent feedback activity.",
          style: TextStyle(
            fontFamily: 'PublicSans',
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
