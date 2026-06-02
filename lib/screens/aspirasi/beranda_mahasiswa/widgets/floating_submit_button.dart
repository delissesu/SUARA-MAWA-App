import 'package:flutter/material.dart';

class FloatingSubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const FloatingSubmitButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      right: 20,
      child: GestureDetector(
        onTap: onPressed ?? () {},
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1A2B5F),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A2B5F).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.note_add_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
