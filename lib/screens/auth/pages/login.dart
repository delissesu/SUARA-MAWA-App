import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:suara_mawa/screens/auth/pages/resetPassword/send_reset.dart';
import 'package:suara_mawa/utils/app_colors.dart';
import 'package:suara_mawa/screens/auth/index.dart';

class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() {
    return _LoginFormState();
  }
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final emailController = TextEditingController(text: '');
  final pwController = TextEditingController(text: '');
  final textStyle = const TextStyle(color: Colors.black, fontSize: 16);
  final errorStyle = const TextStyle(color: Colors.red, fontSize: 16);
  String? errorMsg;
  bool _isLoading = false;
  bool _obscureText = true;
  var emailCheck = (email) => email.endsWith('@mail.unej.ac.id');

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<bool> loginOauth() async {
    try {
      final (is_succes, content) = await _authService.signInGoogle();
      setState(() {
        _isLoading = true;
      });
      if (is_succes) {
        if (content != null && mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login berhasil")));
          // Navigator.pushReplacement(...)
        }
        return true;
      } else if (content == 'OAUTH_LINK_ERROR') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Masuk dengan Google gagal, silakan cek email atau tunggu beberapa saat',
            ),
          ),
        );
        return false;
      } else {
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> loginEmail(String email, String password) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final (isSucces, content) = await _authService.signInEmail(
        email,
        password,
      );
      print("CHeckpoint 1");
      if (isSucces) {
        if (content != null && mounted) {
          print("Token: $content");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Login berhasil")));
        }
        return true;
      } else if (content == 'INVALID_EMAIL_OR_PASSWORD') {
        print("Content: $content");
        setState(() {
          this.errorMsg = "Email atau Password salah, silakan cek kembali";
        });
        return false;
      } else {
        _authService.HandleError(
          content ?? "",
          email: email,
          password: password,
        );
        return false;
      }
    } catch (e) {
      if (mounted) {
        print(e.toString());
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      return false;
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
          Center(
            child: Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 10,
                    children: [
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
                        "Selamat Datang",
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: 2,
                        style: TextStyle(color: Colors.black, fontSize: 26),
                      ),
                      const Text(
                        "Silakan masuk menggunakan email Anda.",
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: 2,
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      if (errorMsg != null)
                        Text(
                          errorMsg!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
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
                      TextFormField(
                        style: textStyle,
                        decoration: InputDecoration(
                          hintStyle: textStyle,
                          hintText: 'Password',
                          labelStyle: textStyle,
                          labelText: 'Password',
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
                        controller: pwController,
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
                      ElevatedButton(
                        onPressed: () async {
                          if (true) {
                            print("running");
                            // _formKey.currentState!.validate()) {

                            final res = await loginEmail(
                              emailController.text,
                              pwController.text,
                            );
                            if (res && mounted) {
                              var (result, kode) = await _authService.checkAuth(
                                ref,
                              );
                              print("res: $result\nCode: $kode");
                              if (!result) {
                                if (mounted) {
                                  _authService.HandleError(kode);
                                }
                              } else {
                                if (mounted) {
                                  _authService.HandleError("SUCCESS");
                                }
                              }
                            }
                            print("runned should not loading");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              )
                            : const Text(
                                "Login",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                      const Row(
                        children: <Widget>[
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: AppColors.inactive,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "Atau",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 1,
                              color: AppColors.inactive,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final res = await loginOauth();
                          if (res && mounted) {
                            var (result, kode) = await _authService.checkAuth(
                              ref,
                            );
                            if (!result) {
                              if (mounted) {
                                _authService.HandleError(kode);
                              }
                            } else {
                              if (mounted) {
                                _authService.HandleError("SUCCESS");
                              }
                            }
                          }
                        },
                        icon: Image.asset(
                          'assets/images/icons/google.png',
                          height: 26,
                        ),
                        label: const Text(
                          'Masuk dengan Akun Google',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.white, // Standard Google button color
                          foregroundColor: Colors.black, // Text and icon color
                          minimumSize: const Size(
                            double.infinity,
                            44,
                          ), // Full width button
                          shape: const StadiumBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          children: [
                            const TextSpan(text: 'Lupa password? '),
                            TextSpan(
                              text: 'Reset Password',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // pindah halaman register
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ResetPasswordPage(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          children: [
                            const TextSpan(text: 'Belum punya akun? '),
                            TextSpan(
                              text: 'Daftar sekarang',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // pindah halaman register
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RegisterPage(),
                                    ),
                                  );
                                },
                            ),
                          ],
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
    );
  }
}
