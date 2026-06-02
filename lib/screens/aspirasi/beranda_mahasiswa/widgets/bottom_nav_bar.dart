import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/aspirasi/beranda_mahasiswa/components/nav_item.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTabChanged;

  const BottomNavBar({super.key, this.currentIndex = 0, this.onTabChanged});

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
              GestureDetector(
                onTap: () => onTabChanged?.call(0),
                behavior: HitTestBehavior.opaque,
                child: NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isActive: currentIndex == 0,
                  activeColor: const Color(0xFF0D1B6E),
                ),
              ),
              GestureDetector(
                onTap: () => onTabChanged?.call(1),
                behavior: HitTestBehavior.opaque,
                child: NavItem(
                  icon: Icons.history_rounded,
                  label: 'History',
                  isActive: currentIndex == 1,
                  activeColor: const Color(0xFF0D1B6E),
                ),
              ),
              GestureDetector(
                onTap: () => onTabChanged?.call(2),
                behavior: HitTestBehavior.opaque,
                child: NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  isActive: currentIndex == 2,
                  activeColor: const Color(0xFF0D1B6E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
