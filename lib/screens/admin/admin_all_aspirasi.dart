import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/admin/admin_dashboard_screen.dart'; // Untuk mengambil AspirasiItem, kNavy, kBg, dll
import 'package:suara_mawa/screens/admin/admin_detail_aspirasi.dart'; // Untuk navigasi ke detail

class AdminAllAspirasiScreen extends StatefulWidget {
  const AdminAllAspirasiScreen({super.key});

  @override
  State<AdminAllAspirasiScreen> createState() => _AdminAllAspirasiScreenState();
}

class _AdminAllAspirasiScreenState extends State<AdminAllAspirasiScreen> {
  String _searchQuery = '';
  String _filterStatus = 'Semua Status';
  String _sortBy = 'Terbaru';

  static const _statusOptions = ['Semua Status', 'Belum Terbaca', 'Proses', 'Selesai'];
  static const _sortOptions = ['Terbaru', 'Judul A-Z', 'Judul Z-A'];

  List<AspirasiItem> get _filteredAndSorted {
    var filtered = daftarAspirasi.where((item) {
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty || 
          item.judul.toLowerCase().contains(q) ||
          item.deskripsi.toLowerCase().contains(q) ||
          item.pelapor.toLowerCase().contains(q);
          
      final matchStatus = _filterStatus == 'Semua Status' || item.status == _filterStatus;
      
      return matchSearch && matchStatus;
    }).toList();

    if (_sortBy == 'Judul A-Z') {
      filtered.sort((a, b) => a.judul.toLowerCase().compareTo(b.judul.toLowerCase()));
    } else if (_sortBy == 'Judul Z-A') {
      filtered.sort((a, b) => b.judul.toLowerCase().compareTo(a.judul.toLowerCase()));
    } else {
      filtered.sort((a, b) => daftarAspirasi.indexOf(a).compareTo(daftarAspirasi.indexOf(b)));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredAndSorted;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: kNavy,
        title: const Text('Semua Aspirasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Cari judul, deskripsi, pelapor...',
                    hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                    filled: true,
                    fillColor: kBg,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kNavy)),
                  ),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _filterDropdown(_filterStatus, _statusOptions, 
                        (v) => setState(() => _filterStatus = v!)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _filterDropdown(_sortBy, _sortOptions, 
                        (v) => setState(() => _sortBy = v!)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_outlined, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text('Tidak ada aspirasi ditemukan', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildAspirasiCard(context, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown(String value, List<String> items, ValueChanged<String?> onChanged) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
            style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
            items: items.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: onChanged,
          ),
        ),
      );

  Widget _buildAspirasiCard(BuildContext context, AspirasiItem item) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => AdminDetailAspirasi(item: item))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]
        ),
        child: Column(
          children: [
            Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: item.iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(item.icon, color: item.iconColor, size: 20)
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.judul, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kNavy)),
                  Text(item.deskripsi, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)), maxLines: 1, overflow: TextOverflow.ellipsis),
                ])
              ),
              const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: item.statusBg, borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  Icon(item.statusIcon, size: 12, color: item.statusColor),
                  const SizedBox(width: 4),
                  Text(item.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: item.statusColor)),
                ])
              ),
              Text(item.waktu, style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
            ]),
          ],
        ),
      ),
    );
  }
}