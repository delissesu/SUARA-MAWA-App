import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:suara_mawa/screens/aspirasi/beranda_mahasiswa/beranda_mahasiswa_screen.dart';
import 'package:suara_mawa/screens/penindak/penindak_main_screen.dart';
import 'package:suara_mawa/utils/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SUARA MAWA',
      theme: ThemeData(fontFamily: 'PublicSans'),
      // home: PenindakMainScreen(),
      home: const BerandaMahasiswaScreen(),
    );
  }
}
