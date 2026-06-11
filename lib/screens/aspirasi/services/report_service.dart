import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:suara_mawa/screens/aspirasi/models/report_model.dart';

/// Centralized service for all Report API operations (mahasiswa side).
///
/// Consumes endpoints documented in `SuaraMawaAPI.txt` under the
/// `/mahasiswa/*` and `/report/*` groups.
class ReportService {
  static const String baseUrl = String.fromEnvironment(
    'SERVER_BASE_URL',
    defaultValue: '',
  );

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {"ngrok-skip-browser-warning": "69420"},
    ),
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Auth helpers

  Future<String?> _getToken() => _storage.read(key: "auth_token");

  Future<Options> _authOptions() async {
    final token = await _getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // Lookup data

  /// `GET /report/category/all`
  Future<List<ReportCategory>> getAllCategories() async {
    final options = await _authOptions();
    final response = await _dio.get('/report/category/all', options: options);
    final list = response.data as List;
    return list
        .map((e) => ReportCategory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `GET /report/department/all`
  Future<List<ReportDepartment>> getAllDepartments() async {
    final options = await _authOptions();
    final response = await _dio.get('/report/department/all', options: options);
    final list = response.data as List;
    return list
        .map((e) => ReportDepartment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// `GET /report/status/all` — returns the enum values as `List<String>`.
  Future<List<String>> getAllStatuses() async {
    final options = await _authOptions();
    final response = await _dio.get('/report/status/all', options: options);
    final list = response.data as List;
    return list.map((e) => e.toString()).toList();
  }

  // Mahasiswa reports

  /// `GET /mahasiswa/my-reports?currentPage=`
  ///
  /// Returns a raw list of [ReportListItem]. The backend does not return
  /// pagination metadata on this endpoint, so we infer `hasMore` from
  /// the length of the returned list.
  Future<List<ReportListItem>> getMyReports({int currentPage = 1}) async {
    final options = await _authOptions();
    final response = await _dio.get(
      '/mahasiswa/my-reports',
      queryParameters: {'currentPage': currentPage},
      options: options,
    );
    final list = response.data as List;
    return list
        .map((e) => ReportListItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Public reports (paginated)

  /// `GET /report/all?currentPage=`
  Future<PaginatedReports> getAllPublicReports({int currentPage = 1}) async {
    final options = await _authOptions();
    final response = await _dio.get(
      '/report/all',
      queryParameters: {'currentPage': currentPage},
      options: options,
    );
    return PaginatedReports.fromJson(response.data as Map<String, dynamic>);
  }

  // Report detail

  /// `POST /report/detail` — body: `{reportId: int}`
  Future<ReportDetail?> getReportDetail(int reportId) async {
    final options = await _authOptions();
    try {
      final response = await _dio.post(
        '/report/detail',
        data: {'reportId': reportId},
        options: options,
      );
      final body = response.data as Map<String, dynamic>;
      if (body['status'] == 'success' && body['data'] != null) {
        return ReportDetail.fromJson(body['data'] as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  // Evidence preview URL

  /// Returns the full URL for previewing an evidence attachment.
  String evidencePreviewUrl(int reportEvidenceId) {
    return '$baseUrl/report/evidence/$reportEvidenceId/preview';
  }

  // Feedback

  /// `POST /report/feedback/detail` — body: `{reportStatusId: int}`
  Future<List<ReportFeedback>> getFeedbackDetail(int reportStatusId) async {
    final options = await _authOptions();
    final response = await _dio.post(
      '/report/feedback/detail',
      data: {'reportStatusId': reportStatusId},
      options: options,
    );
    final list = response.data as List;
    return list
        .map((e) => ReportFeedback.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Create report

  DioMediaType _contentTypeForFile(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    return switch (extension) {
      'jpg' || 'jpeg' => DioMediaType('image', 'jpeg'),
      'png' => DioMediaType('image', 'png'),
      'webp' => DioMediaType('image', 'webp'),
      'heic' => DioMediaType('image', 'heic'),
      'heif' => DioMediaType('image', 'heif'),
      'gif' => DioMediaType('image', 'gif'),
      'mp4' => DioMediaType('video', 'mp4'),
      'mov' => DioMediaType('video', 'quicktime'),
      _ => DioMediaType('application', 'octet-stream'),
    };
  }

  String _messageFromResponseData(Object? data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? data['messgae']?.toString() ?? '';
    }

    if (data is Map) {
      return data['message']?.toString() ?? data['messgae']?.toString() ?? '';
    }

    return data?.toString() ?? '';
  }

  String _fileNameFromPath(String path) {
    return path.replaceAll('\\', '/').split('/').last;
  }

  /// `POST /mahasiswa/report/create`
  ///
  /// Uses multipart/form-data for file uploads. [files] is a list of
  /// image/video [File] objects.
  Future<(bool, String)> createReport({
    required String title,
    required String description,
    required double locationLat,
    required double locationLong,
    String? locationDetail,
    required bool isPublic,
    required int departmentId,
    required int categoryId,
    required List<File> files,
  }) async {
    try {
      final options = await _authOptions();
      options.contentType = 'multipart/form-data';

      final Map<String, dynamic> dataMap = {
        'title': title,
        'description': description,
        'locationLat': locationLat,
        'locationLong': locationLong,
        'isPublic': isPublic.toString(),
        'departmentId': departmentId,
        'categoryId': categoryId,
      };
      if (locationDetail != null) {
        dataMap['locationDetail'] = locationDetail;
      }

      final formData = FormData.fromMap(dataMap);

      for (var i = 0; i < files.length; i++) {
        final file = files[i];
        final fileName = _fileNameFromPath(file.path);
        final contentType = _contentTypeForFile(fileName);

        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
              contentType: contentType,
            ),
          ),
        );
        // Use indexed keys so multipart parsers keep `names` as an array
        // even when only one attachment is uploaded.
        final nameFieldKey = 'names[$i]';
        formData.fields.add(MapEntry(nameFieldKey, fileName));
      }

      final response = await _dio.post(
        '/mahasiswa/report/create',
        data: formData,
        options: options,
      );

      final body = response.data as Map<String, dynamic>;
      final success = body['status'] == 'success';
      final message = _messageFromResponseData(body);
      return (success, message);
    } on DioException catch (e) {
      final responseMessage = _messageFromResponseData(e.response?.data);
      return (
        false,
        responseMessage.isNotEmpty
            ? responseMessage
            : e.message ?? 'Unknown error',
      );
    } catch (e) {
      return (false, 'Client error: $e');
    }
  }
}
