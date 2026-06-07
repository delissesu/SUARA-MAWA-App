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
}
