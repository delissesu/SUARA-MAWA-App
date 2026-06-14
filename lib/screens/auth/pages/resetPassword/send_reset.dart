import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:suara_mawa/utils/app_colors.dart';
import 'package:suara_mawa/screens/auth/index.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: ResetPasswordForm());
  }
}

class ResetPasswordForm extends ConsumerStatefulWidget {
  const ResetPasswordForm({super.key});

  @override
  ConsumerState<ResetPasswordForm> createState() {
    return _ResetPasswordFormState();
  }
}

class _ResetPasswordFormState extends ConsumerState<ResetPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final emailController = TextEditingController(text: '');
  final textStyle = const TextStyle(color: Colors.black, fontSize: 16);
  final errorStyle = const TextStyle(color: Colors.red, fontSize: 16);
  String? msg;
  bool _isLoading = false;
  bool _isSuccess = false;
  var emailCheck = (email) => email.endsWith('@mail.unej.ac.id');

  Future<void> sendResetPassword() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final isSucces = await _authService.sendResetPasswordRequest(
        emailController.text
      );
      if (isSucces) {
        msg = "Berhasil mengirim email reset password. Silakan cek email Anda";
        this._isSuccess = true;
      } else {
        msg = "Terjadi Kesalahan pada Server";
        this._isSuccess = false;
      }
    } catch (e) {
      msg = "Terjadi Error";
      _isSuccess = false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 10,
                  children: [
                    const SizedBox(height: 30,),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ImageIcon(
                          AssetImage('assets/images/icons/speaker.png'),
                          size: 28,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Serap Aspirasi",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      "Lupa Password Anda",
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 2,
                      style: TextStyle(color: Colors.black, fontSize: 26),
                    ),
                    const Text(
                      "Masukkan email untuk kami kirimi link reset password",
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 2,
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    if (msg != null)
                      Text(
                        msg!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isSuccess ? Colors.green : Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    TextFormField(
                      style: textStyle,
                      decoration: InputDecoration(
                        hintStyle: textStyle,
                        hintText: 'email',
                        labelStyle: textStyle,
                        labelText: 'Email',
                        errorStyle: errorStyle,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black,
                            width: 2.0,
                          ),
                        ),
                      ),
                      controller: emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan email';
                        }
                        if (!emailCheck(value)) {
                          return 'Pastikan merupakan email Unej';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: sendResetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      child: const Text(
                        "Kirim Email Reset Password",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 44),
                      ),
                      child: const Text(
                        "Kembali ke Halamn Login",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                        ),
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
    );
  }
}
