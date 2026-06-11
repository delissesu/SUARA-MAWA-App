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
    final response = await _dio.post(
      '/report/detail',
      data: {'reportId': reportId},
      options: options,
    );
    final body = response.data as Map<String, dynamic>;
    if (body['status'] == 'success' && body['data'] != null) {
      return ReportDetail.fromJson(body['data'] as Map<String, dynamic>);
    }
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

  /// `POST /mahasiswa/report/create`
  ///
  /// Uses multipart/form-data for file uploads. [files] is a list of
  /// image/video [File] objects. [names] must have the same length as [files].
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

      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'locationLat': locationLat,
        'locationLong': locationLong,
        if (locationDetail != null) 'locationDetail': locationDetail,
        'isPublic': isPublic.toString(),
        'departmentId': departmentId,
        'categoryId': categoryId,
        'files': await Future.wait(
          files.map((f) => MultipartFile.fromFile(
                f.path,
                filename: f.path.split(Platform.pathSeparator).last,
              )),
        ),
        'names': files
            .map((f) => f.path.split(Platform.pathSeparator).last)
            .toList(),
      });

      final response = await _dio.post(
        '/mahasiswa/report/create',
        data: formData,
        options: options,
      );

      final body = response.data as Map<String, dynamic>;
      return (body['status'] == 'success', body['message']?.toString() ?? '');
    } on DioException catch (e) {
      return (false, e.response?.data?['message']?.toString() ?? e.message ?? 'Unknown error');
    }
  }
}
