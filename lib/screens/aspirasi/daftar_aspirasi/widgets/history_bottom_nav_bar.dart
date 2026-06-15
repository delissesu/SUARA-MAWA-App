import 'package:flutter/material.dart';

class HistoryBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTabChanged;

  const HistoryBottomNavBar({
    super.key,
    this.currentIndex = 1,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onTabChanged?.call(0),
              ),
              _NavItem(
                icon: Icons.history_rounded,
                label: 'Daftar Tugas',
                isActive: currentIndex == 1,
                onTap: () => onTabChanged?.call(1),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                isActive: currentIndex == 2,
                onTap: () => onTabChanged?.call(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF0D1B6E) : Colors.grey.shade500;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PublicSans',
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
