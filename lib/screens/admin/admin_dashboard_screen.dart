import 'package:flutter/material.dart';

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

  static const _navy = Color(0xFF1A2C5B);
  static const _teal = Color(0xFF4DD0C4);
  static const _red = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(children: [
          // --- Top Bar ---
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              CircleAvatar(radius: 20, backgroundColor: _navy, child: const Icon(Icons.person, color: Colors.white, size: 20)),
              const SizedBox(width: 10),
              const Text('Serap Aspirasi', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: _navy)),
              const Spacer(),
              Stack(children: [
                const Icon(Icons.notifications_outlined, size: 26, color: _navy),
                Positioned(top: 2, right: 2, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: _red, shape: BoxShape.circle))),
              ]),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                
                GestureDetector(
                  onTap: () {
                    print('Map Universitas ditekan!');
                  },
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
                        // Markers
                        _marker(top: 55, left: 80, color: _teal, size: 10),
                        _marker(top: 35, left: 190, color: Colors.white54, size: 6),
                        _marker(top: 50, right: 80, color: Colors.white54, size: 6),
                        _marker(top: 75, left: 265, color: _red, size: 12),
                        Positioned(bottom: 18, left: 18, right: 18, child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Map Universitas', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text('Lokasi dari aspirasi yang diajukan.', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8))),
                          ],
                        )),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _statCard('Total\nAspirasi', '3,482', Icons.layers_outlined, Colors.white, _navy, _navy)),
                  const SizedBox(width: 12),
                  Expanded(child: _statCard('Laporan\nBaru', '14', null, const Color(0xFFB2EBF2), const Color(0xFF00838F), const Color(0xFF00838F),
                      iconWidget: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(border: Border.all(color: _navy), borderRadius: BorderRadius.circular(4)),
                        child: const Text('NEW', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _navy)),
                      ),
                      onTap: () {
                        print('Laporan Baru ditekan!');
                      }
                  )),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _statCard('Proses\nVerifikasi', '67', Icons.calendar_today_outlined, const Color(0xFFFFEBEE), _red, _red)),
                  const SizedBox(width: 13),
                ]),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Aspirasi Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _navy)),
                  TextButton(onPressed: () {}, child: const Text('View All', style: TextStyle(color: _navy, fontSize: 13))),
                ]),
                const Divider(height: 8),
                const SizedBox(height: 4),
                
                _card(Icons.lightbulb_outline, const Color(0xFFB2EBF2), const Color(0xFF00838F),
                    'Wifi mati loh yah', 'Wifi di beberapa titik kampus mati sejak pagi, mohon dicek ya...',
                    'Belum terbaca', Icons.circle_outlined, const Color(0xFF00838F), const Color(0xFFB2EBF2), '10 menit yang lalu',
                    onTap: () {
                      print('Aspirasi Wifi ditekan!');
                    }
                ),
                _card(Icons.warning_amber_outlined, const Color(0xFFFFEBEE), _red,
                    'Jalan berlubank', 'Jalan di depan gedung A banyak lubang, bahaya untuk pejalan kaki dan kendaraan.',
                    'Proses', Icons.schedule_outlined, const Color(0xFF757575), const Color(0xFFEEEEEE), '2 jam yang lalu',
                    onTap: () {
                      print('Aspirasi Jalan berlubang ditekan!');
                    }
                ),
                _card(Icons.restaurant_outlined, const Color(0xFFEEEEEE), const Color(0xFF424242),
                    'Gedung kena meteor', 'Gedung B kena meteor kecil, ada kerusakan di atap dan beberapa jendela pecah.',
                    'Telah Selesai', Icons.check_box_outlined, Colors.white, const Color(0xFF1A3C34), '1 hari yang lalu',
                    onTap: () {
                      print('Aspirasi Meteor ditekan!');
                    }
                ),
              ]),
            ),
          ),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        selectedItemColor: _navy,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), label: 'Account\nmanagement'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _marker({double? top, double? left, double? right, required Color color, required double size}) {
    return Positioned(
      top: top, left: left, right: right,
      child: Container(width: size, height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6, spreadRadius: 2)])),
    );
  }

  Widget _statCard(String title, String value, IconData? icon, Color bg, Color titleColor, Color valueColor, {Widget? iconWidget, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: titleColor, height: 1.3))),
            iconWidget ?? Icon(icon, color: titleColor.withOpacity(0.8), size: 20),
          ]),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: valueColor, height: 1.0)),
        ]),
      ),
    );
  }

  Widget _card(IconData icon, Color iconBg, Color iconColor, String title, String subtitle,
      String status, IconData statusIcon, Color statusColor, Color statusBg, String time, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(children: [
          Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 20)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A2C5B))),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
            ])),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                Icon(statusIcon, size: 12, color: statusColor),
                const SizedBox(width: 4),
                Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: statusColor)),
              ])),
            Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
          ]),
        ]),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.07)..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 30) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    for (double x = 0; x < size.width; x += 30) canvas.drawLine(Offset(x, 0), Offset(x + 20, size.height), paint);
  }
  @override bool shouldRepaint(covariant CustomPainter _) => false;
}