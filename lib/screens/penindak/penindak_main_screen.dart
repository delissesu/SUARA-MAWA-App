import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/penindak/dashboard_screen.dart';
import 'package:suara_mawa/screens/penindak/profile_screen.dart';
import 'package:suara_mawa/screens/penindak/task_list_screen.dart';
import 'package:suara_mawa/widgets/shared_main_screen.dart';

class PenindakMainScreen extends StatelessWidget {
  const PenindakMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SharedMainScreen(
      screens: [
        DashboardScreen(),
        TaskListScreen(),
        ProfileScreen(),
      ],
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.assignment_outlined),
          selectedIcon: Icon(Icons.assignment),
          label: 'Daftar Tugas',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}