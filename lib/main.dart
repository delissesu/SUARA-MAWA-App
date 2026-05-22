import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/penindak/penindak_main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUARA MAWA',
      theme: ThemeData(
        fontFamily: 'PublicSans'
      ),
      home: PenindakMainScreen()
    );
  }
}

