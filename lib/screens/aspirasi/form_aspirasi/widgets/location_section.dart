import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../components/section_card.dart';
import '../components/form_field_label.dart';

class LocationSection extends StatefulWidget {
  final LatLng? selectedLocation;
  final VoidCallback? onUseCurrentGps;
  final bool isFetchingGps;
  final ValueChanged<LatLng>? onLocationChanged;
  final TextEditingController? locationDetailController;

  const LocationSection({
    super.key,
    this.selectedLocation,
    this.onUseCurrentGps,
    this.isFetchingGps = false,
    this.onLocationChanged,
    this.locationDetailController,
  });

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  static const String _tag = 'LocationSection';

  // Default: center of Jember, East Java
  static const LatLng _defaultCenter = LatLng(-8.1845, 113.6720);

  static const _inputDecoration = InputDecoration(
    filled: true,
    fillColor: Color(0xFFF8F9FB),
    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Color(0xFFDDE1EA)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Color(0xFFDDE1EA)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Color(0xFF1A2B5F), width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
    ),
  );

  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    developer.log(
      'initState — defaultCenter=$_defaultCenter, '
      'selectedLocation=${widget.selectedLocation}',
      name: _tag,
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LocationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the location changes externally (e.g. GPS result), move the map.
    if (widget.selectedLocation != null &&
        widget.selectedLocation != oldWidget.selectedLocation) {
      developer.log(
        'didUpdateWidget — moving map to ${widget.selectedLocation}',
        name: _tag,
      );
      _mapController.move(widget.selectedLocation!, 15);
    }
  }

  LatLng get _center => widget.selectedLocation ?? _defaultCenter;

  /// Called when the user taps on the map surface to reposition the marker.
  void _handleMapTap(TapPosition tapPosition, LatLng tappedPoint) {
    developer.log(
      '_handleMapTap — lat=${tappedPoint.latitude}, '
      'lng=${tappedPoint.longitude}',
      name: _tag,
    );
    widget.onLocationChanged?.call(tappedPoint);
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.location_on_outlined,
      title: 'Lokasi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Interactive Map
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: 15,
                      // Enable all map interactions (pan, zoom, rotate)
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                      // Tap on map → reposition marker
                      onTap: _handleMapTap,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.suara_mawa',
                      ),
                      // Only show marker when a location is selected
                      if (widget.selectedLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: widget.selectedLocation!,
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
                  // GPS button overlay
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

          // Coordinate feedback
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
              'Ketuk peta atau gunakan GPS untuk menentukan lokasi.',
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),

          //  Detail Lokasi text input
          const SizedBox(height: 16),
          const FormFieldLabel(label: 'Detail Lokasi'),
          TextFormField(
            controller: widget.locationDetailController,
            style: const TextStyle(
              fontFamily: 'PublicSans',
              fontSize: 14,
              color: Color(0xFF0D1B2A),
            ),
            decoration: _inputDecoration.copyWith(
              hintText: 'Cth: Kelas A lantai 2 Gedung utama',
              hintStyle: TextStyle(
                fontFamily: 'PublicSans',
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              prefixIcon: const Icon(
                Icons.edit_location_alt_outlined,
                size: 20,
                color: Color(0xFF1A2B5F),
              ),
            ),
            textInputAction: TextInputAction.done,
            maxLength: 200,
            buildCounter: (context,
                    {required currentLength,
                    required isFocused,
                    required maxLength}) =>
                null, // hide counter
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
              isFetching ? 'Mengambil Lokasi...' : 'Gunakan GPS Saat Ini',
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
