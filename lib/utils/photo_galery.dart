import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<File?> pickImage(BuildContext context) async {
  final picker = ImagePicker();

  return await showModalBottomSheet<File?>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Kamera"),
              onTap: () async {
                final image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 70,
                );

                if (!context.mounted) return;

                Navigator.pop(
                  context,
                  image != null ? File(image.path) : null,
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Galeri"),
              onTap: () async {
                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 70,
                );

                if (!context.mounted) return;

                Navigator.pop(
                  context,
                  image != null ? File(image.path) : null,
                );
              },
            ),
          ],
        ),
      );
    },
  );
}