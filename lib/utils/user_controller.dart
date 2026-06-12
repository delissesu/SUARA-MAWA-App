import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_controller.g.dart';



class User {
  final String id;
  final String name;
  final String email;
  final int? photoProfileId;
  final bool emailVerified;
  final String? phoneNumber;
  final bool phoneNumberVerified;
  final UserRole? userRole;
  final int? userRoleId;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.photoProfileId,
    required this.emailVerified,
    this.phoneNumber,
    required this.phoneNumberVerified,
    this.userRole,
    this.userRoleId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      photoProfileId:
          json['photoProfileId'],
      emailVerified: json['emailVerified'] ?? false,
      phoneNumber: json['phoneNumber'],
      phoneNumberVerified: json['phoneNumberVerified'] ?? false,
      userRole: json['userRole'] != null
          ? UserRole.fromJson(json['userRole'])
          : null,
      userRoleId: json['userRoleId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoProfileId': photoProfileId,
      'emailVerified': emailVerified,
      'phoneNumber': phoneNumber,
      'phoneNumberVerified': phoneNumberVerified,
      'userRole': userRole?.toJson(),
      'userRoleId': userRoleId,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? photoProfileId,
    bool? emailVerified,
    String? phoneNumber,
    bool? phoneNumberVerified,
    UserRole? userRole,
    int? userRoleId
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoProfileId: photoProfileId ?? this.photoProfileId,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneNumberVerified: phoneNumberVerified ?? this.phoneNumberVerified,
      userRole: userRole ?? this.userRole,
      userRoleId: userRoleId ?? this.userRoleId
    );
  }
}

class UserRole {
  final String name;

  UserRole({required this.name});

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }

  UserRole copyWith({String? name}) {
    return UserRole(
      name: name ?? this.name
    );
  }
}

class MahasiswaDetail {
  final String nim;
  // final String faculty;
  // final String major;

  MahasiswaDetail({required this.nim});
  // MahasiswaDetail({required this.nim, required this.faculty, required this.major});

  factory MahasiswaDetail.fromJson(Map<String, dynamic> json) {
    return MahasiswaDetail(
      nim: json['nim'],
      // major: json['major'],
      // faculty: json['faculty']
    );
  }

  Map<String, dynamic> toJson() {
    return {'nim': nim};
  }

  MahasiswaDetail copyWith({
    String? nim,
    // String? faculty,
    // String? major,
  }) {
    return MahasiswaDetail(
      nim: nim ?? this.nim,
      // faculty: faculty ?? this.faculty,
      // major: major ?? this.major
    );
  }
}

class PenindakDetail {
  final String nik;
  final String department;

  PenindakDetail({required this.nik, required this.department});

  factory PenindakDetail.fromJson(Map<String, dynamic> json) {
    return PenindakDetail(nik: json['nik'], department: json['department']);
  }

  Map<String, dynamic> toJson() {
    return {'nik': nik, 'department': department};
  }

  PenindakDetail copyWith({String? nik, String? department}) {
    return PenindakDetail(
      nik: nik ?? this.nik,
      department: department ?? this.department,
    );
  }
}

class AdminDetail {
  final String nik;

  AdminDetail({required this.nik});

  factory AdminDetail.fromJson(Map<String, dynamic> json) {
    return AdminDetail(nik: json['nik']);
  }

  Map<String, dynamic> toJson() {
    return {'nik': nik};
  }

  AdminDetail copyWith({String? nik}) {
    return AdminDetail(nik: nik ?? this.nik);
  }
}

class UserModel {
  final User? user;
  final MahasiswaDetail? mahasiswaDetail;
  final PenindakDetail? penindakDetail;
  final AdminDetail? adminDetail;
  final String? token;

  UserModel({
    this.user,
    this.mahasiswaDetail,
    this.penindakDetail,
    this.adminDetail,
    this.token,
  });

  factory UserModel.initial() {
    return UserModel();
  }

  UserModel copyWith({
    User? user,
    MahasiswaDetail? mahasiswaDetail,
    PenindakDetail? penindakDetail,
    AdminDetail? adminDetail,
  }) {
    return UserModel(
      user: user ?? this.user,
      mahasiswaDetail: mahasiswaDetail ?? this.mahasiswaDetail,
      penindakDetail: penindakDetail ?? this.penindakDetail,
      adminDetail: adminDetail ?? this.adminDetail,
    );
  }
}

@Riverpod(keepAlive: true)
class UserController extends _$UserController {
  @override
  UserModel build() {
    return UserModel.initial(); // initial state
  }

  void update(UserModel model) {
    print(state);
    print(model);

    state = model;
  }

  void updateUserProfile(
    String? name,
    String? prodi,
    int? photoProfileId,
    String? nim,
  ) {
    state = state.copyWith(
      user: state.user?.copyWith(
        name: name,
        // prodi: prodi,
        photoProfileId: photoProfileId,
      ),
    );
  }

  void updateMahasiswaDetail() {
    state = state;
  }

  void updatePenindakDetail() {
    state = state;
  }

  void updateAdminDetail() {
    state = state;
  }

  void destroy() {
    ref.invalidateSelf();
  }
}
