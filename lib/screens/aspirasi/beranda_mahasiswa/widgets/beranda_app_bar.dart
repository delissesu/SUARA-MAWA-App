import 'package:flutter/material.dart';

class BerandaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BerandaAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF0F2F5),
      elevation: 0,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade300,
          child: ClipOval(
            child: Icon(Icons.person, color: Colors.grey.shade600, size: 24),
          ),
        ),
      ),
      title: const Text(
        'Serap Aspirasi',
        style: TextStyle(
          fontFamily: 'PublicSans',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Color(0xFF1A2B5F),
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Icon(
            Icons.notifications_outlined,
            color: Colors.grey.shade700,
            size: 26,
          ),
        ),
      ],
    );
  }
}
