import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:suara_mawa/screens/penindak/models/report.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';

class ReportService {
  static final String _baseUrl = AuthService.baseUrl;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {"ngrok-skip-browser-warning": "69420"},
    ),
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return _storage.read(key: "auth_token");
  }

  /// Public token access for video player
  Future<String?> getToken() async => _getToken();

  /// Returns the full preview URL for video/image streaming
  String getEvidencePreviewUrl(int reportEvidenceId) {
    return '$_baseUrl/report/evidence/$reportEvidenceId/preview';
  }

  /// Fetch the logged-in user's departmentId from /user/me
  Future<int?> getUserDepartmentId() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/user/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;
      // roleDetails.departmentId
      return data['roleDetails']?['departmentId'];
    } on DioException catch (e) {
      print('Error fetching user department: ${e.message}');
      return null;
    }
  }

  /// Fetch reports filtered by departmentId and status
  Future<List<Report>> fetchReports({
    required int departmentId,
    required String status,
  }) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/report/filter',
        queryParameters: {
          'departmentId': departmentId,
          'status': status,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;
      final List<dynamic> items = data['data'] ?? [];
      return items.map((json) => Report.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Error fetching reports: ${e.message}');
      return [];
    }
  }

  /// Fetch the full detail of a single report via POST /report/detail
  Future<Map<String, dynamic>?> fetchReportDetail(int reportId) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '/report/detail',
        data: {'reportId': reportId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['data'];
    } on DioException catch (e) {
      print('Error fetching report detail: ${e.message}');
      return null;
    }
  }

  /// Fetch feedback detail for a specific status entry via POST /report/feedback/detail
  Future<List<dynamic>?> fetchFeedbackDetail(int reportStatusId) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '/report/feedback/detail',
        data: {'reportStatusId': reportStatusId},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;
      if (data is List) return data;
      return null;
    } on DioException catch (e) {
      print('Error fetching feedback detail: ${e.message}');
      return null;
    }
  }

  /// Fetch evidence image bytes for display from GET /report/evidence/:id/preview
  Future<Uint8List?> fetchEvidencePreviewBytes(int reportEvidenceId) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/report/evidence/$reportEvidenceId/preview',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes,
        ),
      );
      return Uint8List.fromList(response.data);
    } on DioException catch (e) {
      print('Error fetching evidence preview: ${e.message}');
      return null;
    }
  }

  /// Fetch evidence video bytes for playback from GET /report/evidence/:id/preview
  Future<Uint8List?> fetchEvidenceVideoBytes(int reportEvidenceId) async {
    return fetchEvidencePreviewBytes(reportEvidenceId);
  }

  /// Returns the full download URL for a document evidence
  String getEvidenceDownloadUrl(int reportEvidenceId) {
    return '$_baseUrl/report/evidence/$reportEvidenceId/download';
  }

  /// Build the full thumbnail URL from the relative path
  String getThumbnailUrl(String relativePath) {
    return '$_baseUrl$relativePath';
  }

  /// Fetch thumbnail image bytes with auth headers
  Future<Uint8List?> fetchThumbnailBytes(String relativePath) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        relativePath,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes,
        ),
      );
      return Uint8List.fromList(response.data);
    } on DioException catch (e) {
      print('Error fetching thumbnail: ${e.message}');
      return null;
    }
  }

  /// Fetch user profile photo bytes
  Future<Uint8List?> fetchProfilePhotoBytes(String relativeUrl) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        relativeUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes,
        ),
      );
      return Uint8List.fromList(response.data);
    } on DioException catch (e) {
      print('Error fetching profile photo: ${e.message}');
      return null;
    }
  }
}
