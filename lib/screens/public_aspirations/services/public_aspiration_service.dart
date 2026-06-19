import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:suara_mawa/screens/public_aspirations/models/public_report.dart';
import 'package:suara_mawa/screens/public_aspirations/models/comment.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';

class PublicAspirationService {
  static final String _baseUrl = AuthService.baseUrl;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {"ngrok-skip-browser-warning": "69420"},
    ),
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: "auth_token");
  }

  Future<List<PublicReport>> getPublicAspirations({int page = 1, int pageSize = 10}) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/report/all', 
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('getPublicAspirations response: ${response.data}');

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) {
          try {
            return PublicReport.fromJson(json);
          } catch (e) {
            print('Error parsing report: $e, json: $json');
            rethrow;
          }
        }).toList();
      }
      throw Exception('Invalid status code: ${response.statusCode}');
    } catch (e) {
      print('Error fetching public aspirations: $e');
      rethrow;
    }
  }

  Future<bool> likeAspiration(int id) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '/report/$id/like',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error liking aspiration: $e');
      return false;
    }
  }

  Future<bool> addComment(int id, String comment) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        '/report/$id/comment', 
        data: {
          'comment': comment,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding comment: $e');
      return false;
    }
  }

  Future<List<Comment>> getComments(int id) async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        '/report/$id/comments',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => Comment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }
}
