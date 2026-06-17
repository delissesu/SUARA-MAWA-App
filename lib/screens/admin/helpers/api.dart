import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';

class Department {
  final int id;
  final String name;

  Department({required this.id, required this.name});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(id: json['id'] as int, name: json['name'] as String);
  }
}

class AuthInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null && err.response!.data != null) {
      AuthService().HandleError(err.response!.data["code"]);
    }
    return handler.next(err);
  }
}

class AdminAPIHelper {
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

  AdminAPIHelper() {
    _dio.interceptors.add(AuthInterceptor());
  }

  Future<String?> getToken() async {
    return _storage.read(key: "auth_token");
  }

  Future<List<Department>> getDepartments() async {
    final token = await this.getToken();
    final result = await _dio.get(
      '/report/department/all',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    print(result.data);
    if (result.data != null) {
      return List<Department>.from(
        (result.data as List).map(
          (e) => Department.fromJson(
            Map<String, dynamic>.from(e),
          ),
        ),
      );
    } else {
      return [];
    }
  }
}
