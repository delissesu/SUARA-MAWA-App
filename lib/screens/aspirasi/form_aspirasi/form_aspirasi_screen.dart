import 'package:flutter/material.dart';
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

  String? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    // TODO: Replace with actual API call via Dio
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Aspiration submitted successfully!',
          style: TextStyle(fontFamily: 'PublicSans'),
        ),
        backgroundColor: const Color(0xFF1B4332),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Navigator.of(context).maybePop();
  }

  void _handleUseCurrentGps() {
    // TODO: Implement Geolocator to get current position
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Fetching GPS location...',
          style: TextStyle(fontFamily: 'PublicSans'),
        ),
        backgroundColor: const Color(0xFF1A2B5F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleTakePhoto() {
    // TODO: Implement image_picker with ImageSource.camera
  }

  void _handleUploadGallery() {
    // TODO: Implement image_picker with ImageSource.gallery
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: const FormAppBar(),
      body: Form(
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
                selectedCategory: _selectedCategory,
                onCategoryChanged: (value) =>
                    setState(() => _selectedCategory = value),
              ),
              const SizedBox(height: 16),
              LocationSection(onUseCurrentGps: _handleUseCurrentGps),
              const SizedBox(height: 16),
              AttachmentsSection(
                onTakePhoto: _handleTakePhoto,
                onUploadGallery: _handleUploadGallery,
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
