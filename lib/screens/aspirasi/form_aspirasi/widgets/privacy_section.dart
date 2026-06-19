import 'package:flutter/material.dart';
import '../components/section_card.dart';

class PrivacySection extends StatelessWidget {
  final bool isPublic;

  final ValueChanged<bool> onChanged;

  const PrivacySection({
    super.key,
    required this.isPublic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.visibility_outlined,
      title: 'Visibilitas Aspirasi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tentukan siapa yang dapat melihat aspirasi Anda',
            style: TextStyle(
              fontFamily: 'PublicSans',
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          _PrivacyRadioTile(
            value: true,
            groupValue: isPublic,
            onChanged: onChanged,
            icon: Icons.public_rounded,
            label: 'Publik',
            description: 'Aspirasi dapat dilihat oleh semua pengguna',
          ),
          const SizedBox(height: 8),
          _PrivacyRadioTile(
            value: false,
            groupValue: isPublic,
            onChanged: onChanged,
            icon: Icons.lock_outline_rounded,
            label: 'Privat',
            description: 'Hanya Anda dan petugas yang dapat melihat',
          ),
        ],
      ),
    );
  }
}

class _PrivacyRadioTile extends StatelessWidget {
  final bool value;
  final bool groupValue;
  final ValueChanged<bool> onChanged;
  final IconData icon;
  final String label;
  final String description;

  const _PrivacyRadioTile({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.icon,
    required this.label,
    required this.description,
  });

  bool get _isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _isSelected
              ? const Color(0xFF1A2B5F).withValues(alpha: 0.06)
              : const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isSelected
                ? const Color(0xFF1A2B5F)
                : const Color(0xFFDDE1EA),
            width: _isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: _isSelected
                  ? const Color(0xFF1A2B5F)
                  : const Color(0xFF9CA3AF),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'PublicSans',
                      fontSize: 14,
                      fontWeight:
                          _isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: _isSelected
                          ? const Color(0xFF0D1B2A)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'PublicSans',
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: value,
              groupValue: groupValue,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
              activeColor: const Color(0xFF1A2B5F),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
