import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/profile/screens/main_screen.dart';



class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16, 0, 16, 0
        ),
        child: SingleChildScrollView(
          child: Column(
            children: const [
              
              ProfilePreview(),

              SizedBox(height: 24), // Jarak profile dan menu

              ProfileOptions(),

            ],
          ),
        ), 
      ),
    );
  }
}