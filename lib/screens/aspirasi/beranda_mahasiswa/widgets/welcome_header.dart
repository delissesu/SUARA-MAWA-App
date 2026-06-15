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
          'Selamat datang kembali,\n$studentName',
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
          "Berikut adalah ringkasan aktivitas laporan Anda baru-baru ini.",
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
