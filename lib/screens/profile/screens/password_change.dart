import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';
import 'package:suara_mawa/utils/app_colors.dart';
import 'package:suara_mawa/utils/photo_galery.dart';
import 'package:suara_mawa/utils/user_controller.dart';
import 'package:suara_mawa/widgets/shared_main_screen.dart';

class UpdatePasswordPage extends ConsumerStatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  ConsumerState<UpdatePasswordPage> createState() {
    return _UpdatePasswordPageState();
  }
}

class _UpdatePasswordPageState extends ConsumerState<UpdatePasswordPage> {
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final newPwController = TextEditingController(text: '');
  final currentPwController = TextEditingController(text: '');
  final textStyle = const TextStyle(color: Colors.black, fontSize: 16);
  final errorStyle = const TextStyle(color: Colors.red, fontSize: 16);
  bool _isLoading = false;
  bool _obscureText = true;
  bool _obscureText2 = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggle2() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }

  @override
  void initState() {
    super.initState();

    newPwController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    currentPwController.dispose();
    newPwController.dispose();
    super.dispose();
  }

  Future<bool> changePassword() async {
    await _authService.sendChangePassword(
      currentPwController.text,
      newPwController.text,
    );
    return true;
  }

  Widget buildRequirement(bool valid, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            valid ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: valid ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: valid ? Colors.green : Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(ref),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        style: textStyle,
                        decoration: InputDecoration(
                          hintStyle: textStyle,
                          hintText: 'Password Saat Ini',
                          labelStyle: textStyle,
                          labelText: 'Password Saat Ini',
                          errorStyle: errorStyle,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Change the icon based on the state
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed:
                                // 4. Update the state to show/hide the password
                                _toggle,
                          ),
                        ),
                        // suffixIcon: Icon(Icons.error),
                        obscureText: _obscureText,
                        controller: currentPwController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }

                          if (value.length < 8) {
                            return 'Password setidaknya memiliki pnjang 8 karakter';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Password harus berisi setidaknya satu huruf besar';
                          }
                          if (!RegExp(r'[a-z]').hasMatch(value)) {
                            return 'Password harus berisi setidaknya satu huruf kecil';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Password harus berisi setidaknya satu angka';
                          }
                          if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
                            return 'Password harus berisi setidaknya satu karakter spesial (!@#\$&*~)';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        style: textStyle,
                        decoration: InputDecoration(
                          hintStyle: textStyle,
                          hintText: 'Password Saat Ini',
                          labelStyle: textStyle,
                          labelText: 'Password Saat Ini',
                          errorStyle: errorStyle,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Change the icon based on the state
                              _obscureText2
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed:
                                // 4. Update the state to show/hide the password
                                _toggle2,
                          ),
                        ),
                        // suffixIcon: Icon(Icons.error),
                        obscureText: _obscureText2,
                        controller: newPwController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }

                          if (value.length < 8) {
                            return 'Password setidaknya memiliki pnjang 8 karakter';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Password harus berisi setidaknya satu huruf besar';
                          }
                          if (!RegExp(r'[a-z]').hasMatch(value)) {
                            return 'Password harus berisi setidaknya satu huruf kecil';
                          }
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Password harus berisi setidaknya satu angka';
                          }
                          if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
                            return 'Password harus berisi setidaknya satu karakter spesial (!@#\$&*~)';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 6),

                      buildRequirement(
                        newPwController.text.length >= 8,
                        'Minimal 8 karakter',
                      ),

                      buildRequirement(
                        RegExp(r'[A-Z]').hasMatch(newPwController.text),
                        'Memiliki huruf besar (A-Z)',
                      ),

                      buildRequirement(
                        RegExp(r'[a-z]').hasMatch(newPwController.text),
                        'Memiliki huruf kecil (a-z)',
                      ),

                      buildRequirement(
                        RegExp(r'[0-9]').hasMatch(newPwController.text),
                        'Memiliki angka (0-9)',
                      ),

                      buildRequirement(
                        RegExp(r'[!@#\$&*~]').hasMatch(newPwController.text),
                        'Memiliki karakter spesial (!@#\$&*~)',
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width:
                            double.infinity, // Expands to full available width
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            // 4. Trigger validation across all fields
                            if (_formKey.currentState!.validate()) {
                              // Process your valid data here
                              setState(() {
                                _isLoading = true;
                              });
                              final (res, msg) = await _authService
                                  .updatePassword(
                                    newPwController.text,
                                    currentPwController.text,
                                  );
                              setState(() {
                                _isLoading = false;
                              });
                              if (res && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Password Berhasil Diperbarui',
                                    ),
                                  ),
                                );
                              } else {
                                final message = msg ?? 'Tidak diketahui';
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Gagal: $message')),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.primary, // Background color
                            foregroundColor:
                                Colors.white, // Text and icon color
                          ),
                          child: const Text('Update Password'),
                        ),
                      ),
                    ],
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
    );
  }
}
