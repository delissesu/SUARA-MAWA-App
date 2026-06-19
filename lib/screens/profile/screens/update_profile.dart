import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';
import 'package:suara_mawa/screens/auth/index.dart';
import 'package:suara_mawa/utils/app_colors.dart';
import 'package:suara_mawa/utils/photo_galery.dart';
import 'package:suara_mawa/utils/user_controller.dart';
import 'package:suara_mawa/widgets/shared_main_screen.dart';

class UpdateProfilePage extends ConsumerStatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  ConsumerState<UpdateProfilePage> createState() {
    return _UpdateProfilePageState();
  }
}

class _UpdateProfilePageState extends ConsumerState<UpdateProfilePage> {
  File? selectedImage;
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final idPhoneRegex = RegExp(r'^(\+62|62|0)8[1-9][0-9]{7,11}$');
  final textStyle = const TextStyle(color: Colors.black, fontSize: 16);
  final errorStyle = const TextStyle(color: Colors.red, fontSize: 16);
  late final TextEditingController nomorHPController;
  late final TextEditingController? nimController;
  late final TextEditingController? nikController;
  late final UserModel userModel;
  late final TextEditingController identityController;
  late final TextEditingController nameController;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    File? image = await pickImage(context);
    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    userModel = ref.read(userControllerProvider);
    final initialValue = userModel.user?.phoneNumber ?? '';
    final identityValue = switch (userModel.user?.userRole?.name) {
      "MAHASISWA" => userModel.mahasiswaDetail?.nim,
      "PENINDAK" => userModel.penindakDetail?.nik,
      "ADMIN" => userModel.adminDetail?.nik,
      _ => "",
    };
    nomorHPController = TextEditingController(text: initialValue);
    identityController = TextEditingController(text: identityValue);
    nameController = TextEditingController(text: userModel.user?.name);
    nomorHPController.addListener(() {
      setState(() {});
    });

    identityController.addListener(() {
      setState(() {});
    });

    nameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    nomorHPController.dispose();
    identityController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });
    bool isMahasiswa = userModel.mahasiswaDetail != null;
    bool noChange = true;
    String? nomorHP, nim, nik, name;
    if (nomorHPController.text != userModel.user?.phoneNumber) {
      noChange = false;
      nomorHP = nomorHPController.text;
    }
    if (isMahasiswa) {
      if (identityController.text != userModel.mahasiswaDetail!.nim) {
        noChange = false;
        nim = identityController.text;
      }
    } else {
      if (userModel.penindakDetail != null) {
        if (identityController.text != userModel.penindakDetail!.nik) {
          noChange = false;
          nik = identityController.text;
        }
      } else {
        if (identityController.text != userModel.adminDetail!.nik) {
          noChange = false;
          nik = identityController.text;
        }
      }
    }
    if (nameController.text != userModel.user?.name) {
      noChange = false;
      name = nameController.text;
    }
    if (selectedImage != null) {
      noChange = false;
    }
    if (noChange) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tidak ada data yang diperbaharui"),
          backgroundColor: Colors.black,
        ),
      );
      return;
    }
    final res = await _authService.updateProfile(
      nim: nim,
      nik: nik,
      phoneNumber: nomorHP,
      name: name,
      file: selectedImage,
    );
    setState(() {
      _isLoading = false;
    });
    if (res && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Profile Berhasil Diperbarui"),
          backgroundColor: Colors.green,
        ),
      );
      if (selectedImage != null) {
        ref.read(userControllerProvider.notifier).updatePhotoProfile();
      }
      ref.read(userControllerProvider.notifier).updateMahasiswaDetail(
        
      );
      if (nomorHPController.text != userModel.user?.phoneNumber && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const FirstPage()),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      _authService.showError("Gagal Update Profile");
    }
  }

  bool get hasChange {
    bool change = false;

    final isMahasiswa = userModel.mahasiswaDetail != null;

    if (nomorHPController.text != userModel.user?.phoneNumber) {
      change = true;
    }

    if (isMahasiswa) {
      if (identityController.text != userModel.mahasiswaDetail!.nim) {
        change = true;
      }
    } else {
      if (userModel.penindakDetail != null) {
        if (identityController.text != userModel.penindakDetail!.nik) {
          change = true;
        }
      } else {
        if (identityController.text != userModel.adminDetail!.nik) {
          change = true;
        }
      }
    }

    if (nameController.text != userModel.user?.name) {
      change = true;
    }

    if (selectedImage != null) {
      change = true;
    }

    print("Ada perubahan: $change");
    return change;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !hasChange,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Konfirmasi'),
            content: const Text(
              'Perubahan belum disimpan. Keluar dari halaman?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Keluar'),
              ),
            ],
          ),
        );

        if (shouldLeave == true && this.mounted) {
          Navigator.pop(this.context);
        }
      },
      child: Scaffold(
        appBar: buildAppBar(ref),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color.fromARGB(170, 0, 0, 0),
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(45),
                              child: selectedImage != null
                                  ? Image.file(
                                      selectedImage!,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    )
                                  : CircleAvatar(
                                      radius: 50,
                                      backgroundImage: NetworkImage(
                                        "${const String.fromEnvironment('SERVER_BASE_URL', defaultValue: '')}/users/${ref.watch(userControllerProvider.select((um) => um.user?.name))}/profile/photo?dump=${ref.watch(userControllerProvider.select((um) => um.counter))}",
                                        headers: {
                                          'Authorization':
                                              "Bearer ${ref.watch(userControllerProvider.select((um) => um.token))}",
                                        },
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          TextButton(
                            onPressed: _pickImage,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue,
                              textStyle: const TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: const Text("Edit"),
                          ),

                          if (selectedImage != null)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedImage = null;
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                textStyle: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              child: const Text("Hapus Foto"),
                            ),

                          const SizedBox(height: 16),
                          TextFormField(
                            style: textStyle,
                            decoration: InputDecoration(
                              hintStyle: textStyle,
                              hintText: 'Nama',
                              labelStyle: textStyle,
                              labelText: 'Nama',
                              errorStyle: errorStyle,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            controller: nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Masukkan nama';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            style: textStyle,
                            inputFormatters: [
                              TextInputFormatter.withFunction((
                                oldValue,
                                newValue,
                              ) {
                                if (RegExp(
                                  r'^\+?[0-9]*$',
                                ).hasMatch(newValue.text)) {
                                  return newValue;
                                }
                                return oldValue;
                              }),
                            ],
                            decoration: InputDecoration(
                              hintStyle: textStyle,
                              hintText: 'Nomor Telepon',
                              labelStyle: textStyle,
                              labelText: 'Nomor Telepon',
                              errorStyle: errorStyle,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            controller: nomorHPController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Masukkan nomor telepon';
                              }
                              if (!idPhoneRegex.hasMatch(value)) {
                                return 'Cek kembali nomor telepon';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Mengganti nomor telepon akan memerlukan verifikasi dengan OTP",
                          ),

                          const SizedBox(height: 16),
                          if (userModel.mahasiswaDetail != null)
                            MahasiswaDetailForm(
                              identityController: identityController,
                            ),
                          if (userModel.penindakDetail != null)
                            PenindakDetailForm(
                              identityController: identityController,
                            ),
                          if (userModel.adminDetail != null)
                            AdminDetailForm(
                              identityController: identityController,
                            ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double
                                .infinity, // Expands to full available width
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _isLoading = true);
                                  await _updateProfile();
                                  setState(() => _isLoading = false);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    AppColors.primary, // Background color
                                foregroundColor:
                                    Colors.white, // Text and icon color
                              ),
                              child: const Text("Perbarui", style: TextStyle()),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                const Opacity(
                  opacity: 0.6,
                  child: ModalBarrier(dismissible: false, color: Colors.black),
                ),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

class IdentityTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const IdentityTextField({
    super.key,
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$label wajib diisi';
        }
        return null;
      },
    );
  }
}

class MahasiswaDetailForm extends ConsumerStatefulWidget {
  final TextEditingController identityController;
  const MahasiswaDetailForm({super.key, required this.identityController});

  @override
  ConsumerState<MahasiswaDetailForm> createState() {
    return _MahasiswaDetailFormState();
  }
}

class _MahasiswaDetailFormState extends ConsumerState<MahasiswaDetailForm> {
  final textStyle = const TextStyle(color: Colors.black, fontSize: 16);

  @override
  void initState() {
    super.initState();
    // nipController = TextEditingController(ref.read(userControllerProvider.select((m)=>m.penindakDetail?.nip)));
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(color: Colors.black54, fontSize: 16);
    return TextFormField(
      style: textStyle,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: const InputDecoration(
        hintStyle: textStyle,
        hintText: 'NIM',
        labelStyle: textStyle,
        labelText: 'NIM (Tidak dapat diubah)',
        errorStyle: TextStyle(color: Colors.red, fontSize: 16),
        filled: true,
        fillColor: Color(0xFFF0F2F5),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black38, width: 2.0),
        ),
      ),
      controller: widget.identityController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Masukkan NIM';
        }
        return null;
      },
    );
  }
}

class PenindakDetailForm extends ConsumerStatefulWidget {
  final TextEditingController identityController;
  const PenindakDetailForm({super.key, required this.identityController});

  @override
  ConsumerState<PenindakDetailForm> createState() => _PenindakDetailFormState();
}

class _PenindakDetailFormState extends ConsumerState<PenindakDetailForm> {
  // late final nipController;

  @override
  void initState() {
    super.initState();
    // nipController = TextEditingController(ref.read(userControllerProvider.select((m)=>m.penindakDetail?.nip)));
  }

  @override
  void dispose() {
    // nipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IdentityTextField(controller: widget.identityController, label: 'NIK'),
        // const SizedBox(height: 16),
        // IdentityTextField(controller: nipController, label: 'NIP'),
      ],
    );
  }
}

class AdminDetailForm extends ConsumerStatefulWidget {
  final TextEditingController identityController;
  const AdminDetailForm({super.key, required this.identityController});

  @override
  ConsumerState<AdminDetailForm> createState() => _AdminDetailFormState();
}

class _AdminDetailFormState extends ConsumerState<AdminDetailForm> {
  // final nipController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // nipController = TextEditingController(ref.read(userControllerProvider.select((m)=>m.penindakDetail?.nip)));
  }

  @override
  void dispose() {
    // nipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IdentityTextField(controller: widget.identityController, label: 'NIK'),
        // const SizedBox(height: 16),
        // IdentityTextField(controller: nipController, label: 'NIP'),
      ],
    );
  }
}
