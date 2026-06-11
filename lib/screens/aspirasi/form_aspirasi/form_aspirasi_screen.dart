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
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
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
  List<File> _attachments = [];

  @override
  void initState() {
    super.initState();
    _loadLookupData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingLookups = false);
    }
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedCategoryId == null) {
      _showSnackBar('Please select a category', isError: true);
      return;
    }
    if (_selectedDepartmentId == null) {
      _showSnackBar('Please select a department', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final (success, message) = await _reportService.createReport(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        locationLat: _selectedLocation?.latitude ?? 0.0,
        locationLong: _selectedLocation?.longitude ?? 0.0,
        locationDetail: null,
        isPublic: true,
        departmentId: _selectedDepartmentId!,
        categoryId: _selectedCategoryId!,
        files: _attachments,
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (success) {
        _showSnackBar('Aspiration submitted successfully!');
        Navigator.of(context).maybePop();
      } else {
        _showSnackBar(message.isNotEmpty ? message : 'Failed to submit', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSnackBar('Submission error: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (isError) {
      debugPrint('FormAspirasi Error: $message');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'PublicSans'),
        ),
        backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF1B4332),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: isError
            ? SnackBarAction(
                label: 'Copy',
                textColor: Colors.white,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: message));
                },
              )
            : null,
      ),
    );
  }

  Future<void> _handleUseCurrentGps() async {
    setState(() => _isFetchingGps = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        _showSnackBar('Location services are disabled.', isError: true);
        setState(() => _isFetchingGps = false);
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          _showSnackBar('Location permission denied.', isError: true);
          setState(() => _isFetchingGps = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        _showSnackBar('Location permissions are permanently denied.', isError: true);
        setState(() => _isFetchingGps = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _isFetchingGps = false;
      });
      _showSnackBar('Location captured successfully!');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isFetchingGps = false);
      _showSnackBar('GPS error: $e', isError: true);
    }
  }

  Future<void> _handleTakePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (image != null && mounted) {
        setState(() => _attachments.add(File(image.path)));
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Could not open camera.', isError: true);
    }
  }

  Future<void> _handleUploadGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (images.isNotEmpty && mounted) {
        setState(() {
          _attachments.addAll(images.map((img) => File(img.path)));
        });
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Could not open gallery.', isError: true);
    }
  }

  void _handleRemoveAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: const FormAppBar(),
      body: _isLoadingLookups
          ? const Center(child: CircularProgressIndicator())
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
    );
  }
}
