import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/aspirasi/beranda_mahasiswa/beranda_mahasiswa_screen.dart';
import 'package:suara_mawa/screens/aspirasi/daftar_aspirasi/daftar_aspirasi_screen.dart';
import 'package:suara_mawa/screens/aspirasi/profile/profile_screen.dart';
import 'package:suara_mawa/widgets/shared_main_screen.dart';

class AspirasiMainScreen extends StatelessWidget {
  const AspirasiMainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SharedMainScreen(
      screens: [
        BerandaMahasiswaScreen(),
        DaftarAspirasiScreen(),
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
