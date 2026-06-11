import 'dart:io';
import 'package:flutter/material.dart';
import '../components/section_card.dart';
import '../components/attachment_button.dart';

class AttachmentsSection extends StatelessWidget {
  final VoidCallback? onTakePhoto;
  final VoidCallback? onUploadGallery;
  final List<File> attachments;
  final ValueChanged<int>? onRemoveAttachment;

  const AttachmentsSection({
    super.key,
    this.onTakePhoto,
    this.onUploadGallery,
    this.attachments = const [],
    this.onRemoveAttachment,
  });

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.attach_file_rounded,
      title: 'Attachments',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AttachmentButton(
            icon: Icons.camera_alt_outlined,
            label: 'Take Photo',
            onPressed: onTakePhoto,
          ),
          const SizedBox(height: 10),
          AttachmentButton(
            icon: Icons.image_outlined,
            label: 'Upload Gallery',
            onPressed: onUploadGallery,
          ),
          if (attachments.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: attachments.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  return _AttachmentThumbnail(
                    file: attachments[index],
                    onRemove: () => onRemoveAttachment?.call(index),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'Supported formats: JPG, PNG. Max size: 5MB.',
            style: TextStyle(
              fontFamily: 'PublicSans',
              fontWeight: FontWeight.w400,
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentThumbnail extends StatelessWidget {
  final File file;
  final VoidCallback? onRemove;

  const _AttachmentThumbnail({required this.file, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            file,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEDEEF2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.broken_image_outlined, color: Color(0xFF5C6B8A)),
            ),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
