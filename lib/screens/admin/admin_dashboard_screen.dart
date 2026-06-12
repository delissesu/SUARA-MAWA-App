// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
//import 'package:suara_mawa/screens/admin/admin_account_management.dart';
import 'package:suara_mawa/screens/admin/admin_fullmap.dart';
import 'package:suara_mawa/screens/admin/admin_detail_aspirasi.dart';

const kNavy  = Color(0xFF1A2C5B);
const kTeal  = Color(0xFF4DD0C4);
const kRed   = Color(0xFFE53935);
const kBg    = Color(0xFFF5F6FA);

class AspirasiItem {
  final String judul, deskripsi, status, waktu, lokasi, pelapor;
  final IconData icon;
  final Color iconBg, iconColor, statusBg, statusColor;
  final IconData statusIcon;

  const AspirasiItem({
    required this.judul, required this.deskripsi, required this.status,
    required this.waktu,  required this.lokasi,    required this.pelapor,
    required this.icon,   required this.iconBg,    required this.iconColor,
    required this.statusBg, required this.statusColor, required this.statusIcon,
  });
}

final List<AspirasiItem> daftarAspirasi = [
  AspirasiItem(
    judul: 'Wifi mati loh yah',
    deskripsi: 'Wifi di beberapa titik kampus mati sejak pagi, mohon dicek ya...',
    lokasi: 'Gedung A – Lantai 2', pelapor: 'Budi Santoso',
    status: 'Belum Terbaca', waktu: '10 menit yang lalu',
    icon: Icons.wifi_off_outlined,
    iconBg: const Color(0xFFB2EBF2), iconColor: const Color(0xFF00838F),
    statusBg: const Color(0xFFB2EBF2), statusColor: const Color(0xFF00838F),
    statusIcon: Icons.circle_outlined,
  ),
  AspirasiItem(
    judul: 'Jalan berlubang',
    deskripsi: 'Jalan di depan gedung A banyak lubang, bahaya untuk pejalan kaki.',
    lokasi: 'Depan Gedung A', pelapor: 'Siti Rahayu',
    status: 'Proses', waktu: '2 jam yang lalu',
    icon: Icons.warning_amber_outlined,
    iconBg: const Color(0xFFFFEBEE), iconColor: kRed,
    statusBg: const Color(0xFFEEEEEE), statusColor: const Color(0xFF757575),
    statusIcon: Icons.schedule_outlined,
  ),
  AspirasiItem(
    judul: 'Gedung kena meteor',
    deskripsi: 'Gedung B kena meteor kecil, ada kerusakan di atap dan beberapa jendela pecah.',
    lokasi: 'Gedung B – Atap', pelapor: 'Agus Wijaya',
    status: 'Selesai', waktu: '1 hari yang lalu',
    icon: Icons.restaurant_outlined,
    iconBg: const Color(0xFFEEEEEE), iconColor: const Color(0xFF424242),
    statusBg: const Color(0xFF1A3C34), statusColor: Colors.white,
    statusIcon: Icons.check_box_outlined,
  ),
];

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardAdmin(),
    ));

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});
  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  int _navIndex = 0;

  final _pages = const [
    _DashboardBody(),
    //adminAccountManagement(),
    _ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(child: Column(children: [
        _TopBar(),
        Expanded(child: _pages[_navIndex]),
      ])),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        selectedItemColor: kNavy,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),           label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.manage_accounts_outlined), label: 'Akun'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),           label: 'Profil'),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        const CircleAvatar(radius: 20, backgroundColor: kNavy,
            child: Icon(Icons.person, color: Colors.white, size: 20)),
        const SizedBox(width: 10),
        const Text('Serap Aspirasi',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: kNavy)),
        const Spacer(),
        Stack(children: [
          const Icon(Icons.notifications_outlined, size: 26, color: kNavy),
          Positioned(top: 2, right: 2, child: Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: kRed, shape: BoxShape.circle))),
        ]),
      ]),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Banner peta
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdminFullMap())),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 190,
              decoration: const BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFF2A3D6B), Color(0xFF3A5090), Color(0xFF4A6BA8)]),
              ),
              child: Stack(children: [
                CustomPaint(size: const Size(double.infinity, 190), painter: _GridPainter()),
                _dot(top: 55, left: 80,  color: kTeal,          size: 10),
                _dot(top: 35, left: 190, color: Colors.white54,  size: 6),
                _dot(top: 50, right: 80, color: Colors.white54,  size: 6),
                _dot(top: 75, left: 265, color: kRed,            size: 12),
                Positioned(bottom: 18, left: 18, right: 18,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Map Universitas',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 4),
                    Text('Lokasi dari aspirasi yang diajukan.',
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20)),
                        child: const Row(children: [
                          Icon(Icons.open_in_full, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Lihat Full Map', style: TextStyle(fontSize: 11, color: Colors.white)),
                        ]),
                      ),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Stat cards
        Row(children: [
          Expanded(child: _statCard('Total\nAspirasi', '3,482', Icons.layers_outlined,
              Colors.white, kNavy, kNavy)),
          const SizedBox(width: 12),
          Expanded(child: _statCard('Laporan\nBaru', '14', null,
              const Color(0xFFB2EBF2), const Color(0xFF00838F), const Color(0xFF00838F),
              iconWidget: _newBadge())),
        ]),
        const SizedBox(height: 12),
        _statCard('Proses\nVerifikasi', '67', Icons.pending_actions_outlined,
            const Color(0xFFFFEBEE), kRed, kRed),
        const SizedBox(height: 20),
        // Recent aspirasi
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Aspirasi Baru',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kNavy)),
          TextButton(onPressed: () {},
              child: const Text('Lihat Semua', style: TextStyle(color: kNavy, fontSize: 13))),
        ]),
        const Divider(height: 8),
        const SizedBox(height: 4),
        ...daftarAspirasi.map((a) => _AspirasiCard(item: a)),
      ]),
    );
  }

  static Widget _dot({double? top, double? left, double? right, required Color color, required double size}) =>
      Positioned(top: top, left: left, right: right,
        child: Container(width: size, height: size,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6, spreadRadius: 2)])));

  static Widget _newBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    decoration: BoxDecoration(border: Border.all(color: kNavy), borderRadius: BorderRadius.circular(4)),
    child: const Text('NEW', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: kNavy)),
  );

  static Widget _statCard(String title, String value, IconData? icon,
      Color bg, Color titleColor, Color valueColor, {Widget? iconWidget}) =>
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(title,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: titleColor, height: 1.3))),
            iconWidget ?? Icon(icon, color: titleColor.withOpacity(0.8), size: 20),
          ]),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: valueColor, height: 1.0)),
        ]),
      );
}

class _AspirasiCard extends StatelessWidget {
  final AspirasiItem item;
  const _AspirasiCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => AdminDetailAspirasi(item: item))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(children: [
          Row(children: [
            Container(width: 42, height: 42,
                decoration: BoxDecoration(color: item.iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(item.icon, color: item.iconColor, size: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(item.judul,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kNavy)),
              Text(item.deskripsi,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(color: item.statusBg, borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                Icon(item.statusIcon, size: 12, color: item.statusColor),
                const SizedBox(width: 4),
                Text(item.status,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: item.statusColor)),
              ])),
            Text(item.waktu, style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
          ]),
        ]),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();
  @override
  Widget build(BuildContext context) => const Center(
    child: Text('Profil', style: TextStyle(fontSize: 18, color: kNavy, fontWeight: FontWeight.w600)),
  );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.07)..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 30)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    for (double x = 0; x < size.width; x += 30)
      canvas.drawLine(Offset(x, 0), Offset(x + 20, size.height), p);
  }
  @override bool shouldRepaint(covariant CustomPainter _) => false;
}