import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final _formKey = GlobalKey<FormState>();
  final idPhoneRegex = RegExp(r'^(\+62|62|0)8[1-9][0-9]{7,11}$');
  final textStyle = const TextStyle(color: Colors.black, fontSize: 16);
  final errorStyle = const TextStyle(color: Colors.red, fontSize: 16);
  late final TextEditingController nomorHPController;
  late final UserModel userModel;
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
    nomorHPController = TextEditingController(text: initialValue);
  }

  @override
  void dispose() {
    nomorHPController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(ref),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
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
                                    "${const String.fromEnvironment('SERVER_BASE_URL', defaultValue: '')}/users/${ref.watch(userControllerProvider.select((um) => um.user?.name))}/profile/photo",
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

                      const SizedBox(height: 16),

                      TextFormField(
                        style: textStyle,
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) {
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
                      const SizedBox(height: 16),
                      if (userModel.mahasiswaDetail != null)
                        MahasiswaDetailForm(),
                      if (userModel.penindakDetail != null)
                        PenindakDetailForm(),
                      if (userModel.adminDetail != null) AdminDetailForm(),
                      
                      const SizedBox(height: 20),
                      
                      SizedBox(
                        width: double.infinity, // Expands to full available width
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);
                              
                              setState(() => _isLoading = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,     // Background color
                            foregroundColor: Colors.white,    // Text and icon color
                          ),
                          child: const Text("Perbarui", style: TextStyle()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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
  const MahasiswaDetailForm({super.key});

  @override
  ConsumerState<MahasiswaDetailForm> createState() {
    return _MahasiswaDetailFormState();
  }
}

class _MahasiswaDetailFormState extends ConsumerState<MahasiswaDetailForm> {
  late final nimController;
  final textStyle = const TextStyle(color: Colors.black, fontSize: 16);

  @override
  void initState() {
    super.initState();
    nimController = TextEditingController(
      text: ref.read(
        userControllerProvider.select((m) => m.mahasiswaDetail?.nim),
      ),
    );
    // nipController = TextEditingController(ref.read(userControllerProvider.select((m)=>m.penindakDetail?.nip)));
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: textStyle,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        hintStyle: textStyle,
        hintText: 'NIM',
        labelStyle: textStyle,
        labelText: 'NIM',
        errorStyle: const TextStyle(color: Colors.red, fontSize: 16),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 2.0),
        ),
      ),
      controller: nimController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Masukkan password';
        }
        return null;
      },
    );
  }
}

class PenindakDetailForm extends ConsumerStatefulWidget {
  const PenindakDetailForm({super.key});

  @override
  ConsumerState<PenindakDetailForm> createState() => _PenindakDetailFormState();
}

class _PenindakDetailFormState extends ConsumerState<PenindakDetailForm> {
  late final nikController;
  // late final nipController;

  @override
  void initState() {
    super.initState();
    nikController = TextEditingController(
      text: ref.read(
        userControllerProvider.select((m) => m.penindakDetail?.nik),
      ),
    );
    // nipController = TextEditingController(ref.read(userControllerProvider.select((m)=>m.penindakDetail?.nip)));
  }

  @override
  void dispose() {
    nikController.dispose();
    // nipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IdentityTextField(controller: nikController, label: 'NIK'),
        // const SizedBox(height: 16),
        // IdentityTextField(controller: nipController, label: 'NIP'),
      ],
    );
  }
}

class AdminDetailForm extends ConsumerStatefulWidget {
  const AdminDetailForm({super.key});

  @override
  ConsumerState<AdminDetailForm> createState() => _AdminDetailFormState();
}

class _AdminDetailFormState extends ConsumerState<AdminDetailForm> {
  late final nikController;
  // final nipController = TextEditingController();
  @override
  void initState() {
    super.initState();
    nikController = TextEditingController(
      text: ref.read(userControllerProvider.select((m) => m.adminDetail?.nik)),
    );
    // nipController = TextEditingController(ref.read(userControllerProvider.select((m)=>m.penindakDetail?.nip)));
  }

  @override
  void dispose() {
    nikController.dispose();
    // nipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IdentityTextField(controller: nikController, label: 'NIK'),
        // const SizedBox(height: 16),
        // IdentityTextField(controller: nipController, label: 'NIP'),
      ],
    );
  }
}
