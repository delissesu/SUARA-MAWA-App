// lib/screens/admin/admin_fullmap.dart
import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/admin/admin_dashboard_screen.dart';
import 'package:suara_mawa/screens/admin/admin_detail_aspirasi.dart';

class AdminFullMap extends StatefulWidget {
  const AdminFullMap({super.key});
  @override
  State<AdminFullMap> createState() => _AdminFullMapState();
}

class _AdminFullMapState extends State<AdminFullMap> {
  String _filter = 'Semua';
  int? _hoveredIndex;

  final _filters = ['Semua', 'Belum Terbaca', 'Proses', 'Selesai'];

  // Posisi marker relatif pada canvas (x%, y%)
  final List<_MapMarker> _markers = [
    _MapMarker(label: 'Wifi mati loh yah',    x: 0.22, y: 0.30, color: const Color(0xFF00838F), index: 0),
    _MapMarker(label: 'Jalan berlubang',       x: 0.55, y: 0.50, color: kRed,                   index: 1),
    _MapMarker(label: 'Gedung kena meteor',    x: 0.75, y: 0.25, color: const Color(0xFF424242), index: 2),
    _MapMarker(label: 'Lampu mati',            x: 0.40, y: 0.70, color: kNavy,                   index: 1),
    _MapMarker(label: 'Parkir sempit',         x: 0.65, y: 0.75, color: const Color(0xFF00838F), index: 0),
  ];

  List<_MapMarker> get _filteredMarkers => _filter == 'Semua'
      ? _markers
      : _markers.where((m) => daftarAspirasi[m.index % daftarAspirasi.length].status == _filter).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: kNavy,
        elevation: 0,
        centerTitle: false,
        title: const Text('Full Map Aspirasi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kNavy)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined, color: kNavy),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: Column(children: [
        // ── Filter chips ───────────────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: _filters.map((f) {
              final active = _filter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? kNavy : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? kNavy : const Color(0xFFE0E0E0)),
                    ),
                    child: Text(f, style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500,
                        color: active ? Colors.white : Colors.grey)),
                  ),
                ),
              );
            }).toList()),
          ),
        ),

        // ── Map canvas ─────────────────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF1E3060), Color(0xFF2A4A8A), Color(0xFF1A3C6E)],
                    ),
                  ),
                  child: Stack(children: [
                    // Grid background
                    CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: _FullGridPainter()),
                    // Bangunan / zona (dekorasi)
                    ..._buildZones(constraints),
                    // Markers
                    ..._filteredMarkers.map((m) {
                      final x = m.x * constraints.maxWidth;
                      final y = m.y * constraints.maxHeight;
                      return Positioned(
                        left: x - 18, top: y - 18,
                        child: GestureDetector(
                          onTap: () {
                            final item = daftarAspirasi[m.index % daftarAspirasi.length];
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => AdminDetailAspirasi(item: item)));
                          },
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: m.color.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: m.color, width: 2),
                              ),
                              child: Center(child: Container(
                                width: 12, height: 12,
                                decoration: BoxDecoration(color: m.color, shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: m.color.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)]),
                              )),
                            ),
                          ]),
                        ),
                      );
                    }),
                    // Legend
                    Positioned(top: 12, right: 12, child: _legend()),
                    // Jumlah marker
                    Positioned(bottom: 12, left: 12, child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.black45, borderRadius: BorderRadius.circular(10)),
                      child: Text('${_filteredMarkers.length} aspirasi ditampilkan',
                          style: const TextStyle(fontSize: 11, color: Colors.white)),
                    )),
                  ]),
                );
              }),
            ),
          ),
        ),

        // ── Daftar singkat di bawah ────────────────────────────────────────────
        Container(
          height: 200,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Lokasi Aspirasi',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kNavy)),
                Text('${_filteredMarkers.length} titik',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ]),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filteredMarkers.length,
                itemBuilder: (_, i) {
                  final m = _filteredMarkers[i];
                  final item = daftarAspirasi[m.index % daftarAspirasi.length];
                  return GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => AdminDetailAspirasi(item: item))),
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 10, bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: kBg, borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE8E8E8))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Container(width: 8, height: 8,
                              decoration: BoxDecoration(color: m.color, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Expanded(child: Text(m.label,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kNavy),
                              maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ]),
                        const SizedBox(height: 6),
                        Text(item.lokasi,
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(color: item.statusBg, borderRadius: BorderRadius.circular(10)),
                          child: Text(item.status,
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: item.statusColor)),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _legend() => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _legendItem(const Color(0xFF00838F), 'Belum Terbaca'),
      const SizedBox(height: 4),
      _legendItem(kRed, 'Proses'),
      const SizedBox(height: 4),
      _legendItem(const Color(0xFF424242), 'Selesai'),
    ]),
  );

  Widget _legendItem(Color color, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label, style: const TextStyle(fontSize: 9, color: Colors.white)),
  ]);

  List<Widget> _buildZones(BoxConstraints c) => [
    _zone(c, 0.10, 0.15, 0.30, 0.20, 'Gedung A'),
    _zone(c, 0.50, 0.15, 0.30, 0.20, 'Gedung B'),
    _zone(c, 0.10, 0.55, 0.25, 0.25, 'Parkir'),
    _zone(c, 0.55, 0.60, 0.30, 0.20, 'Kantin'),
  ];

  Widget _zone(BoxConstraints c, double lPct, double tPct, double wPct, double hPct, String label) =>
      Positioned(
        left: lPct * c.maxWidth, top: tPct * c.maxHeight,
        width: wPct * c.maxWidth, height: hPct * c.maxHeight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Center(child: Text(label,
              style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w500))),
        ),
      );
}

class _MapMarker {
  final String label;
  final double x, y;
  final Color color;
  final int index;
  const _MapMarker({required this.label, required this.x, required this.y,
      required this.color, required this.index});
}

class _FullGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.06)..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 40)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    for (double x = 0; x < size.width; x += 40)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
  }
  @override bool shouldRepaint(covariant CustomPainter _) => false;
}