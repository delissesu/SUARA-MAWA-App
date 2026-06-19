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
          (e) => Department.fromJson(Map<String, dynamic>.from(e)),
        ),
      );
    } else {
      return [];
    }
  }

  Future<UserPageData?> getUsers({
    String? keyword,
    int? userRoleId,
    String page = "1",
  }) async {
    final token = await this.getToken();
    String url = '/user/get-all?page=$page';
    if (userRoleId != null) url += '&userRoleId=$userRoleId';
    if (keyword != null) url += '&keyword=$keyword';
    final result = await _dio.get(
      url,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    print(result.data);
    if (result.data != null) {
      return UserPageData.fromJson(result.data);
    } else {
      return null;
    }
  }
}

class User {
  String name, email, role, lastLogin, id;
  String departemenId, nik, noTelp, nim;

  User({
    required this.name,
    required this.email,
    required this.role,
    this.lastLogin = '',
    this.id = '',
    this.departemenId = '',
    this.nik = '',
    // this.nip = '',
    this.noTelp = '',
    this.nim = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final nik = json['mahasiswaDeatils']!=null ? (json['penindakDetails'] != null 
        ? json['penindakDetails']["nik"]
        : json['adminDetails']['nik']) : '';
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['userRole']['name'],
      lastLogin: json['lastLogin']??"Belum Pernah Login",
      departemenId: json['penindakDetails']?["department"]["id"].toString() ?? '',
      nik: nik,
      noTelp: json['phoneNumber']??'Belum Menambahkan Nomor Telepon',
      nim: json['mahasiswaDetails']?['nim'] ?? '',
    );
  }
}

class UserPageData {
  List<User> data;
  PageMetaData metaData;

  UserPageData({required this.data, required this.metaData});

  factory UserPageData.fromJson(Map<String, dynamic> json) {
    return UserPageData(
      data: List<User>.from(
        (json['data'] as List).map(
          (e) => User.fromJson(Map<String, dynamic>.from(e)),
        ),
      ),
      metaData: PageMetaData.fromJson(json['meta']),
    );
  }
}

class PageMetaData {
  int totalRows;
  int totalPages;
  int currentPages;
  int pageSize;
  PageMetaData({
    required this.totalRows,
    required this.totalPages,
    required this.currentPages,
    required this.pageSize,
  });

  factory PageMetaData.fromJson(Map<String, dynamic> json) {
    return PageMetaData(
      totalRows: json['totalRows'],
      totalPages: json['totalPages'],
      currentPages: json['currentPage'],
      pageSize: json['PAGE_SIZE'],
    );
  }
}
