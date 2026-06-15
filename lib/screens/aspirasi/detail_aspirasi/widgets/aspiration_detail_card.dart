import 'package:flutter/material.dart';
import '../components/info_section_card.dart';

class AspirationDetailCard extends StatelessWidget {
  final String description;

  const AspirationDetailCard({super.key, required this.description});

  @override
  Widget build(BuildContext context) {
    return InfoSectionCard(
      icon: Icons.description_outlined,
      title: 'Detail Aspirasi',
      child: Text(
        description,
        style: TextStyle(
          fontFamily: 'PublicSans',
          fontWeight: FontWeight.w400,
          fontSize: 13,
          height: 1.6,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}
