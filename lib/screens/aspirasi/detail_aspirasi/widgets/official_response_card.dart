import 'package:flutter/material.dart';
import '../models/detail_aspirasi_model.dart';
import '../components/info_section_card.dart';

class OfficialResponseCard extends StatelessWidget {
  final OfficialResponse response;

  const OfficialResponseCard({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    return InfoSectionCard(
      icon: Icons.mark_chat_read_outlined,
      title: 'Tanggapan Resmi',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFB2EBF2),
            ),
            child: const Center(
              child: Icon(
                Icons.shield_outlined,
                size: 22,
                color: Color(0xFF00838F),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Responder name + time ago
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        response.responderName,
                        style: const TextStyle(
                          fontFamily: 'PublicSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF0D1B2A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      response.timeAgo,
                      style: TextStyle(
                        fontFamily: 'PublicSans',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Response message in tinted container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    response.message,
                    style: TextStyle(
                      fontFamily: 'PublicSans',
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
