import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../components/section_card.dart';

class LocationSection extends StatefulWidget {
  final LatLng? selectedLocation;
  final VoidCallback? onUseCurrentGps;
  final bool isFetchingGps;

  const LocationSection({
    super.key,
    this.selectedLocation,
    this.onUseCurrentGps,
    this.isFetchingGps = false,
  });

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  // Default: center of Jember, East Java
  static const LatLng _defaultCenter = LatLng(-8.1845, 113.6720);

  late final MapController _mapController;

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

  @override
  void didUpdateWidget(covariant LocationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the location changes, move the map to the new center.
    if (widget.selectedLocation != null &&
        widget.selectedLocation != oldWidget.selectedLocation) {
      _mapController.move(widget.selectedLocation!, 15);
    }
  }

  LatLng get _center => widget.selectedLocation ?? _defaultCenter;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.location_on_outlined,
      title: 'Location',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 180,
              child: Stack(
                children: [
                  FlutterMap(
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
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _GpsButton(
                        onPressed: widget.onUseCurrentGps,
                        isFetching: widget.isFetchingGps,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (widget.selectedLocation != null)
            Text(
              'Lat: ${widget.selectedLocation!.latitude.toStringAsFixed(6)}, '
              'Lng: ${widget.selectedLocation!.longitude.toStringAsFixed(6)}',
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            )
          else
            Text(
              'Pinpoint the exact location of the observation.',
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
        ],
      ),
    );
  }
}

class _GpsButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isFetching;

  const _GpsButton({this.onPressed, this.isFetching = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isFetching ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFetching)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Color(0xFF1A2B5F)),
                ),
              )
            else
              const Icon(Icons.my_location_rounded, size: 16, color: Color(0xFF1A2B5F)),
            const SizedBox(width: 6),
            Text(
              isFetching ? 'Getting Location...' : 'Use Current GPS',
              style: const TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF1A2B5F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
