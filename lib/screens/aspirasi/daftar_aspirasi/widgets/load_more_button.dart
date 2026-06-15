import 'package:flutter/material.dart';

class LoadMoreButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const LoadMoreButton({super.key, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCDD1DC), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1A2B5F),
                  ),
                )
              : const Text(
                  'Muat Lebih Banyak',
                  style: TextStyle(
                    fontFamily: 'PublicSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
        ),
      ),
    );
  }
}
