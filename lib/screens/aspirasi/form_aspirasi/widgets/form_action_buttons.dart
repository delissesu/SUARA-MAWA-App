import 'package:flutter/material.dart';

class FormActionButtons extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onSubmit;
  final bool isLoading;

  const FormActionButtons({
    super.key,
    this.onCancel,
    this.onSubmit,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: isLoading
                ? null
                : (onCancel ?? () => Navigator.of(context).maybePop()),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCDD1DC), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF5C6B8A),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: isLoading ? null : onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0D1B6E),
              disabledBackgroundColor: const Color(
                0xFF0D1B6E,
              ).withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send_rounded, size: 18, color: Colors.white),
            label: Text(
              isLoading ? 'Mengirimkan...' : 'Kirim Aspirasi',
              style: const TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
