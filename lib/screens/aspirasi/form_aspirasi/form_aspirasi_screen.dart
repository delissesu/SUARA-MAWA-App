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
  static const int _maxAttachmentBytes = 5 * 1024 * 1024;
  static const Set<String> _allowedAttachmentExtensions = {
    'jpg',
    'jpeg',
    'png',
  };

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
        location: null,
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
        _showSnackBar(
          message.isNotEmpty ? message : 'Failed to submit',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSnackBar('Submission error: $e', isError: true);
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
        _showSnackBar(
          'Location permissions are permanently denied.',
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
      _showSnackBar('Could not open camera.', isError: true);
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
            '$rejectedCount attachment(s) skipped. Use JPG/PNG up to 5MB.',
            isError: true,
          );
        }
      }
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Could not open gallery.', isError: true);
    }
  }

  void _handleRemoveAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  Future<String?> _validateAttachment(File file) async {
    final exists = await file.exists();
    if (!exists) {
      return 'Attachment file not found.';
    }

    final extension = _extensionForFile(file);
    final sizeInBytes = await file.length();

    if (!_allowedAttachmentExtensions.contains(extension)) {
      return 'Only JPG and PNG attachments are supported.';
    }

    if (sizeInBytes > _maxAttachmentBytes) {
      return 'Attachment must be 5MB or smaller.';
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
