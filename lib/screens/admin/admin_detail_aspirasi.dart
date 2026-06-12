import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/admin/admin_dashboard_screen.dart';

class AdminDetailAspirasi extends StatefulWidget {
  final AspirasiItem item;
  const AdminDetailAspirasi({super.key, required this.item});

  @override
  State<AdminDetailAspirasi> createState() => _AdminDetailAspirasiState();
}

class _AdminDetailAspirasiState extends State<AdminDetailAspirasi> {
  late String _currentStatus;

  final _statusOptions = ['Belum Terbaca', 'Proses', 'Selesai', 'Ditolak'];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.item.status;
  }

  Color get _statusColor {
    switch (_currentStatus) {
      case 'Selesai':       return const Color(0xFF1A3C34);
      case 'Proses':        return const Color(0xFFEEEEEE);
      case 'Ditolak':       return const Color(0xFFFFEBEE);
      default:              return const Color(0xFFB2EBF2);
    }
  }

  Color get _statusTextColor {
    switch (_currentStatus) {
      case 'Selesai':       return Colors.white;
      case 'Proses':        return const Color(0xFF757575);
      case 'Ditolak':       return kRed;
      default:              return const Color(0xFF00838F);
    }
  }

  IconData get _statusIcon {
    switch (_currentStatus) {
      case 'Selesai':  return Icons.check_box_outlined;
      case 'Proses':   return Icons.schedule_outlined;
      case 'Ditolak':  return Icons.cancel_outlined;
      default:         return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: kNavy,
        elevation: 0,
        centerTitle: false,
        title: const Text('Detail Aspirasi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kNavy)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 48, height: 48,
                    decoration: BoxDecoration(color: item.iconBg, borderRadius: BorderRadius.circular(14)),
                    child: Icon(item.icon, color: item.iconColor, size: 24)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.judul,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kNavy)),
                  const SizedBox(height: 2),
                  Text(item.waktu, style: const TextStyle(fontSize: 11, color: Color(0xFFBDBDBD))),
                ])),
              ]),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFF0F0F0)),
              const SizedBox(height: 10),
              const Text('Deskripsi',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
              const SizedBox(height: 6),
              Text(item.deskripsi,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF333333), height: 1.6)),
            ]),
          ),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: _infoTile(Icons.location_on_outlined, 'Lokasi', item.lokasi)),
            const SizedBox(width: 10),
            Expanded(child: _infoTile(Icons.person_outline, 'Pelapor', item.pelapor)),
          ]),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Status Aspirasi',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kNavy)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: _statusColor, borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_statusIcon, size: 13, color: _statusTextColor),
                  const SizedBox(width: 5),
                  Text(_currentStatus,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _statusTextColor)),
                ]),
              ),
              const SizedBox(height: 14),
              const Text('Ubah Status',
                  style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(10),
                    color: kBg),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currentStatus,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: kNavy),
                    items: _statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s,
                        style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (v) => setState(() => _currentStatus = v!),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Catatan Admin',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kNavy)),
              const SizedBox(height: 10),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tulis catatan tindak lanjut...',
                  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                  filled: true, fillColor: kBg,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: kNavy,
                side: const BorderSide(color: kNavy),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Kembali', style: TextStyle(fontWeight: FontWeight.w600)),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Status diperbarui: $_currentStatus'),
                    backgroundColor: kNavy,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kNavy, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w600)),
            )),
          ]),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 18, color: kNavy),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kNavy)),
      ])),
    ]),
  );
}