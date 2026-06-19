import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import 'package:suara_mawa/screens/aspirasi/services/report_service.dart';

class RevisionFeedbackDialog extends StatefulWidget {
  final int reportId;
  final ReportService reportService;
  final VoidCallback onSuccess;

  const RevisionFeedbackDialog({
    super.key,
    required this.reportId,
    required this.reportService,
    required this.onSuccess,
  });

  @override
  State<RevisionFeedbackDialog> createState() =>
      _RevisionFeedbackDialogState();
}

class _RevisionFeedbackDialogState extends State<RevisionFeedbackDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  final List<File> _selectedFiles = [];
  final List<String> _fileNames = [];
  bool _isSubmitting = false;

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.pickFiles(
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          for (final path in result.paths) {
            if (path != null) {
              _selectedFiles.add(File(path));
              _fileNames.add(path.replaceAll('\\', '/').split('/').last);
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih file: $e')),
        );
      }
    }
  }

  Future<void> _showCameraOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt,
                  color: Color(0xFF1A2B5F)),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                _captureMedia(isVideo: false);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.videocam, color: Color(0xFF1A2B5F)),
              title: const Text('Ambil Video'),
              onTap: () {
                Navigator.pop(context);
                _captureMedia(isVideo: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureMedia({required bool isVideo}) async {
    try {
      final picker = ImagePicker();

      if (isVideo) {
        final pickedFile = await picker.pickVideo(
          source: ImageSource.camera,
          maxDuration: const Duration(minutes: 5),
        );
        if (pickedFile == null) return;

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Mengkompresi video…'),
                ],
              ),
            ),
          );
        }

        final mediaInfo = await VideoCompress.compressVideo(
          pickedFile.path,
          quality: VideoQuality.MediumQuality,
          deleteOrigin: true,
          includeAudio: true,
        );

        if (mounted) Navigator.of(context).pop();

        if (mediaInfo != null && mediaInfo.file != null) {
          setState(() {
            _selectedFiles.add(mediaInfo.file!);
            _fileNames.add(pickedFile.name);
          });
        }
      } else {
        final pickedFile = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 50,
          maxWidth: 1080,
          maxHeight: 1080,
        );
        if (pickedFile == null) return;

        setState(() {
          _selectedFiles.add(File(pickedFile.path));
          _fileNames.add(pickedFile.name);
        });
      }
    } catch (e) {
      // Dismiss any compression dialog still showing.
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil media: $e')),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
      _fileNames.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final (success, message) = await widget.reportService.createFeedback(
        reportId: widget.reportId,
        status: 'pending', // Transition: revision → pending
        description: _descriptionController.text.trim(),
        files: _selectedFiles.isEmpty ? null : _selectedFiles,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggapan revisi berhasil dikirim'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        Navigator.pop(context);
        widget.onSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message.isNotEmpty
                ? message
                : 'Gagal mengirim tanggapan'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                _buildInfoBanner(),
                const SizedBox(height: 20),

                const Text(
                  'Tanggapan',
                  style: TextStyle(
                    fontFamily: 'PublicSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText:
                        'Jelaskan revisi atau perbaikan yang telah dilakukan…',
                    hintStyle: TextStyle(
                      fontFamily: 'PublicSans',
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Color(0xFF1A2B5F), width: 1.5),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'PublicSans',
                    fontSize: 14,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Tanggapan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                const Text(
                  'Lampiran (Opsional)',
                  style: TextStyle(
                    fontFamily: 'PublicSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                _buildAttachmentButtons(),
                if (_selectedFiles.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildAttachmentList(),
                ],
                const SizedBox(height: 24),

                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.reply_rounded, size: 20, color: Color(0xFF1A2B5F)),
            SizedBox(width: 8),
            Text(
              'Tanggapi Revisi',
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D1B2A),
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 22),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: 'Tutup',
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: Color(0xFFE65100)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Penindak meminta revisi atas aspirasi Anda. '
              'Berikan tanggapan atau data tambahan agar proses '
              'dapat dilanjutkan.',
              style: TextStyle(
                fontFamily: 'PublicSans',
                fontSize: 12,
                color: Color(0xFFBF360C),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickFiles,
            icon: const Icon(Icons.attach_file, size: 18),
            label: const Text(
              'Pilih File',
              style: TextStyle(fontFamily: 'PublicSans', fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1A2B5F),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showCameraOptions,
            icon: const Icon(Icons.camera_alt, size: 18),
            label: const Text(
              'Kamera',
              style: TextStyle(fontFamily: 'PublicSans', fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1A2B5F),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _selectedFiles.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
        itemBuilder: (_, index) => ListTile(
          dense: true,
          leading: const Icon(
            Icons.insert_drive_file,
            size: 20,
            color: Color(0xFF1A2B5F),
          ),
          title: Text(
            _fileNames[index],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'PublicSans',
              fontSize: 13,
            ),
          ),
          trailing: IconButton(
            icon:
                const Icon(Icons.close, size: 18, color: Colors.redAccent),
            onPressed: () => _removeFile(index),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Hapus',
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A2B5F),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF1A2B5F).withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Kirim Tanggapan',
                style: TextStyle(
                  fontFamily: 'PublicSans',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
      ),
    );
  }
}
