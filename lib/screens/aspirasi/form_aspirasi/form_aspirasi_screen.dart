import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:suara_mawa/screens/aspirasi/models/report_model.dart';
import 'package:suara_mawa/screens/aspirasi/services/report_service.dart';
import 'widgets/form_app_bar.dart';
import 'widgets/form_page_header.dart';
import 'widgets/aspiration_details_section.dart';
import 'widgets/location_section.dart';
import 'widgets/attachments_section.dart';
import 'widgets/form_action_buttons.dart';

class FormAspirasiScreen extends StatefulWidget {
  const FormAspirasiScreen({super.key});

  @override
  State<FormAspirasiScreen> createState() => _FormAspirasiScreenState();
}

class _FormAspirasiScreenState extends State<FormAspirasiScreen> {
  static const String _tag = 'FormAspirasiScreen';
  static const int _maxAttachmentBytes = 5 * 1024 * 1024;
  static const Set<String> _allowedAttachmentExtensions = {
    'jpg',
    'jpeg',
    'png',
  };

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationDetailController = TextEditingController();
  final ReportService _reportService = ReportService();
  final ImagePicker _imagePicker = ImagePicker();

  int? _selectedCategoryId;
  int? _selectedDepartmentId;
  bool _isSubmitting = false;
  bool _isLoadingLookups = true;
  LatLng? _selectedLocation;
  bool _isFetchingGps = false;

  List<ReportCategory> _categories = [];
  List<ReportDepartment> _departments = [];
  final List<File> _attachments = [];

  @override
  void initState() {
    super.initState();
    _loadLookupData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationDetailController.dispose();
    super.dispose();
  }

  Future<void> _loadLookupData() async {
    try {
      final results = await Future.wait([
        _reportService.getAllCategories(),
        _reportService.getAllDepartments(),
      ]);

      if (!mounted) return;
      setState(() {
        _categories = results[0] as List<ReportCategory>;
        _departments = results[1] as List<ReportDepartment>;
        _isLoadingLookups = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingLookups = false);
    }
  }

  Future<void> _handleSubmit() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return;

    if (_selectedCategoryId == null) {
      _showSnackBar('Silakan pilih kategori', isError: true);
      return;
    }
    if (_selectedDepartmentId == null) {
      _showSnackBar('Silakan pilih tujuan unit kerja', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final locationDetail = _locationDetailController.text.trim();
      developer.log(
        '_handleSubmit — lat=${_selectedLocation?.latitude}, '
        'lng=${_selectedLocation?.longitude}, '
        'locationDetail="$locationDetail"',
        name: _tag,
      );

      final (success, message) = await _reportService.createReport(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        locationLat: _selectedLocation?.latitude ?? 0.0,
        locationLong: _selectedLocation?.longitude ?? 0.0,
        location: locationDetail.isNotEmpty ? locationDetail : null,
        isPublic: true,
        departmentId: _selectedDepartmentId!,
        categoryId: _selectedCategoryId!,
        files: _attachments,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (success) {
        _showSnackBar('Aspirasi berhasil dikirim!');
        Navigator.of(context).maybePop();
      } else {
        _showSnackBar(
          message.isNotEmpty ? message : 'Gagal mengirim aspirasi',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSnackBar('Kesalahan pengiriman: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'PublicSans'),
        ),
        backgroundColor: isError
            ? Colors.red.shade700
            : const Color(0xFF1B4332),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: isError
            ? SnackBarAction(
                label: 'Salin',
                textColor: Colors.white,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: message));
                },
              )
            : null,
      ),
    );
  }

  void _handleLocationChanged(LatLng newLocation) {
    developer.log(
      '_handleLocationChanged — lat=${newLocation.latitude}, '
      'lng=${newLocation.longitude}',
      name: _tag,
    );
    setState(() => _selectedLocation = newLocation);
  }

  Future<void> _handleUseCurrentGps() async {
    developer.log('_handleUseCurrentGps — starting GPS fetch', name: _tag);
    setState(() => _isFetchingGps = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        developer.log('_handleUseCurrentGps — location services disabled', name: _tag);
        if (!mounted) return;
        _showSnackBar('Layanan lokasi dinonaktifkan.', isError: true);
        setState(() => _isFetchingGps = false);
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          developer.log('_handleUseCurrentGps — permission denied', name: _tag);
          if (!mounted) return;
          _showSnackBar('Izin lokasi ditolak.', isError: true);
          setState(() => _isFetchingGps = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        developer.log('_handleUseCurrentGps — permission denied forever', name: _tag);
        if (!mounted) return;
        _showSnackBar(
          'Izin lokasi ditolak secara permanen.',
          isError: true,
        );
        setState(() => _isFetchingGps = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      developer.log(
        '_handleUseCurrentGps — position captured: '
        'lat=${position.latitude}, lng=${position.longitude}',
        name: _tag,
      );

      if (!mounted) return;
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isFetchingGps = false;
      });
      _showSnackBar('Lokasi berhasil diambil!');
    } catch (e) {
      developer.log('_handleUseCurrentGps — error: $e', name: _tag);
      if (!mounted) return;
      setState(() => _isFetchingGps = false);
      _showSnackBar('Kesalahan GPS: $e', isError: true);
    }
  }

  Future<void> _handleTakePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      if (image != null && mounted) {
        final file = File(image.path);
        final error = await _validateAttachment(file);
        if (!mounted) return;

        if (error != null) {
          _showSnackBar(error, isError: true);
          return;
        }

        setState(() => _attachments.add(file));
      }
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Tidak dapat membuka kamera.', isError: true);
    }
  }

  Future<void> _handleUploadGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      if (images.isNotEmpty && mounted) {
        final acceptedFiles = <File>[];
        var rejectedCount = 0;

        for (var i = 0; i < images.length; i++) {
          final image = images[i];
          final file = File(image.path);
          final error = await _validateAttachment(file);
          if (error == null) {
            acceptedFiles.add(file);
          } else {
            rejectedCount++;
          }
        }

        if (!mounted) return;

        if (acceptedFiles.isNotEmpty) {
          setState(() => _attachments.addAll(acceptedFiles));
        }

        if (rejectedCount > 0) {
          _showSnackBar(
            '$rejectedCount lampiran dilewati. Gunakan JPG/PNG maks. 5MB.',
            isError: true,
          );
        }
      }
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Tidak dapat membuka galeri.', isError: true);
    }
  }

  void _handleRemoveAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  Future<String?> _validateAttachment(File file) async {
    final exists = await file.exists();
    if (!exists) {
      return 'File lampiran tidak ditemukan.';
    }

    final extension = _extensionForFile(file);
    final sizeInBytes = await file.length();

    if (!_allowedAttachmentExtensions.contains(extension)) {
      return 'Hanya mendukung lampiran JPG dan PNG.';
    }

    if (sizeInBytes > _maxAttachmentBytes) {
      return 'Ukuran lampiran harus 5MB atau lebih kecil.';
    }

    return null;
  }

  String _fileNameForFile(File file) {
    return file.path.replaceAll('\\', '/').split('/').last;
  }

  String _extensionForFile(File file) {
    final fileName = _fileNameForFile(file);
    final dotIndex = fileName.lastIndexOf('.');

    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return '';
    }

    return fileName.substring(dotIndex + 1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: const FormAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: _isLoadingLookups
            ? const Center(
                key: ValueKey('loading'),
                child: CircularProgressIndicator(),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const FormPageHeader(),
                      const SizedBox(height: 24),
                      AspirationDetailsSection(
                        titleController: _titleController,
                        descriptionController: _descriptionController,
                        selectedCategoryId: _selectedCategoryId,
                        categories: _categories,
                        onCategoryChanged: (value) =>
                            setState(() => _selectedCategoryId = value),
                        selectedDepartmentId: _selectedDepartmentId,
                        departments: _departments,
                        onDepartmentChanged: (value) =>
                            setState(() => _selectedDepartmentId = value),
                      ),
                      const SizedBox(height: 16),
                      LocationSection(
                        selectedLocation: _selectedLocation,
                        onUseCurrentGps: _handleUseCurrentGps,
                        isFetchingGps: _isFetchingGps,
                        onLocationChanged: _handleLocationChanged,
                        locationDetailController: _locationDetailController,
                      ),
                      const SizedBox(height: 16),
                      AttachmentsSection(
                        onTakePhoto: _handleTakePhoto,
                        onUploadGallery: _handleUploadGallery,
                        attachments: _attachments,
                        onRemoveAttachment: _handleRemoveAttachment,
                      ),
                      const SizedBox(height: 32),
                      FormActionButtons(
                        isLoading: _isSubmitting,
                        onSubmit: _handleSubmit,
                        onCancel: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
