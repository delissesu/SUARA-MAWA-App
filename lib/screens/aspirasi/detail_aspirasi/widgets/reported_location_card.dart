import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../components/info_section_card.dart';

class ReportedLocationCard extends StatefulWidget {
  final String address;
  final LatLng? coordinates;

  const ReportedLocationCard({
    super.key,
    required this.address,
    this.coordinates,
  });

  @override
  State<ReportedLocationCard> createState() => _ReportedLocationCardState();
}

class _ReportedLocationCardState extends State<ReportedLocationCard> {
  late final MapController _mapController;

  // Default: center of Jember, East Java
  static const LatLng _defaultCoords = LatLng(-8.1845, 113.6720);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  LatLng get _center => widget.coordinates ?? _defaultCoords;

  @override
  Widget build(BuildContext context) {
    return InfoSectionCard(
      icon: Icons.location_on_outlined,
      title: 'Lokasi Laporan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.address,
            style: TextStyle(
              fontFamily: 'PublicSans',
              fontWeight: FontWeight.w400,
              fontSize: 13,
              height: 1.5,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 160,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.suara_mawa',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _center,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Color(0xFF1A2B5F),
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
