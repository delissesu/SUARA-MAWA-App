import 'package:flutter/material.dart';

class SubmitBanner extends StatelessWidget {
  final VoidCallback? onSubmitPressed;

  const SubmitBanner({super.key, this.onSubmitPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B6E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.campaign_outlined,
              size: 110,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Punya sesuatu untuk disampaikan?',
                style: TextStyle(
                  fontFamily: 'PublicSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kirimkan aspirasi, keluhan, atau saran Anda secara langsung kepada pihak pengelola kampus.',
                style: TextStyle(
                  fontFamily: 'PublicSans',
                  fontWeight: FontWeight.w400,
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onSubmitPressed ?? () {},
                icon: const Icon(Icons.add, size: 16, color: Color(0xFF0D1B6E)),
                label: const Text(
                  'Kirim Aspirasi',
                  style: TextStyle(
                    fontFamily: 'PublicSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF0D1B6E),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
