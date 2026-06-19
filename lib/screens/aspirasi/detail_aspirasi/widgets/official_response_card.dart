import 'package:flutter/material.dart';
import '../models/detail_aspirasi_model.dart';
import '../components/info_section_card.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';
import 'package:suara_mawa/screens/aspirasi/services/report_service.dart';
import 'package:suara_mawa/widgets/media_preview_dialogs.dart';

class OfficialResponseCard extends StatelessWidget {
  final OfficialResponse response;

  const OfficialResponseCard({super.key, required this.response});

  void _showImagePopup(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder<String?>(
              future: AuthService().getToken(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                final token = snapshot.data;
                final headers = <String, String>{
                  'ngrok-skip-browser-warning': '69420',
                };
                if (token != null) {
                  headers['Authorization'] = 'Bearer $token';
                }
                return InteractiveViewer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      headers: headers,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, color: Colors.white, size: 80),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _previewDocument(BuildContext context, String pdfUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => PdfViewerDialog(
        pdfUrl: pdfUrl,
      ),
    );
  }

  void _showVideoPopup(BuildContext context, String videoUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => VideoPlayerDialog(
        videoUrl: videoUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InfoSectionCard(
      icon: Icons.mark_chat_read_outlined,
      title: 'Tanggapan Resmi',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar (shows profile photo if exists, otherwise responder initial)
          ClipOval(
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFB2EBF2),
              ),
              child: response.avatarUrl != null
                  ? FutureBuilder<String?>(
                      future: AuthService().getToken(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        final token = snapshot.data;
                        final headers = <String, String>{
                          'ngrok-skip-browser-warning': '69420',
                        };
                        if (token != null) {
                          headers['Authorization'] = 'Bearer $token';
                        }
                        return Image.network(
                          '${AuthService.baseUrl}${response.avatarUrl}',
                          fit: BoxFit.cover,
                          headers: headers,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                response.avatarLabel,
                                style: const TextStyle(
                                  fontFamily: 'PublicSans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF00838F),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        response.avatarLabel,
                        style: const TextStyle(
                          fontFamily: 'PublicSans',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF00838F),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Responder name + time ago
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        response.responderName,
                        style: const TextStyle(
                          fontFamily: 'PublicSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: Color(0xFF0D1B2A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      response.timeAgo,
                      style: TextStyle(
                        fontFamily: 'PublicSans',
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Response message in tinted container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    response.message,
                    style: TextStyle(
                      fontFamily: 'PublicSans',
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                if (response.attachments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Lampiran:',
                    style: TextStyle(
                      fontFamily: 'PublicSans',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF0D1B2A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: response.attachments.length,
                      itemBuilder: (context, index) {
                        final attachment = response.attachments[index];
                        final file = attachment.file;
                        if (file == null) return const SizedBox.shrink();

                        final filetype = file.filetype.toLowerCase();
                        final previewUrl = ReportService().feedbackAttachmentPreviewUrl(attachment.id);

                        return GestureDetector(
                          onTap: () {
                            if (filetype == 'image') {
                              _showImagePopup(context, previewUrl);
                            } else if (filetype == 'video') {
                              _showVideoPopup(context, previewUrl);
                            } else if (filetype == 'document') {
                              _previewDocument(context, previewUrl);
                            }
                          },
                          child: Container(
                            width: 90,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Background Preview / Icon
                                if (filetype == 'image')
                                  FutureBuilder<String?>(
                                    future: AuthService().getToken(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                        );
                                      }
                                      final token = snapshot.data;
                                      final headers = <String, String>{
                                        'ngrok-skip-browser-warning': '69420',
                                      };
                                      if (token != null) {
                                        headers['Authorization'] = 'Bearer $token';
                                      }
                                      return Image.network(
                                        previewUrl,
                                        fit: BoxFit.cover,
                                        headers: headers,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.broken_image, color: Colors.grey),
                                      );
                                    },
                                  )
                                else if (filetype == 'video')
                                  Container(
                                    color: Colors.black87,
                                    child: const Center(
                                      child: Icon(Icons.play_circle_outline, color: Colors.white, size: 36),
                                    ),
                                  )
                                else if (filetype == 'document')
                                  const Center(
                                    child: Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
                                  )
                                else
                                  const Center(
                                    child: Icon(Icons.insert_drive_file, color: Colors.grey, size: 36),
                                  ),

                                // Title/type overlay
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    color: Colors.black.withOpacity(0.6),
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Text(
                                      file.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontFamily: 'PublicSans',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
