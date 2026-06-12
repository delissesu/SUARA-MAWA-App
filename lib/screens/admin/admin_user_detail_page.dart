import 'package:flutter/material.dart';

class UserDetailPage extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String departemenId;
  final String nik;
  final String nip;
  final String noTelp;
  final String nim;

  const UserDetailPage({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    this.departemenId = '',
    this.nik = '',
    this.nip = '',
    this.noTelp = '',
    this.nim = '',
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Detail Pengguna', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: primaryNavy,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bagian Profil Singkat Atas
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: primaryNavy.withOpacity(0.1),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryNavy),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getRoleColor(role).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            role,
                            style: TextStyle(color: _getRoleColor(role), fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const Divider(height: 40, thickness: 1, color: Color(0xFFF5F5F5)),
              
              if (role == 'Mahasiswa') ...[
                _buildInfoRow(Icons.email_outlined, 'Email', email),
                _buildInfoRow(Icons.badge_outlined, 'NIM', nim),
              ] else ...[
                _buildInfoRow(Icons.domain, 'Departemen ID', departemenId),
                _buildInfoRow(Icons.email_outlined, 'Email', email),
                _buildInfoRow(Icons.credit_card, 'NIK', nik),
                _buildInfoRow(Icons.badge_outlined, 'NIP', nip),
                _buildInfoRow(Icons.phone_outlined, 'Nomor Telepon', noTelp),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  value.trim().isEmpty ? '-' : value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF424242)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    if (role == 'Admin') return const Color(0xFF1E88E5);
    if (role == 'Penindak') return const Color(0xFF43A047);
    return const Color(0xFFFB8C00);
  }
}