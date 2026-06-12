import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';
import 'package:suara_mawa/screens/auth/index.dart';
import 'package:suara_mawa/utils/app_colors.dart';

class RegisterForm extends ConsumerStatefulWidget {
  const RegisterForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _RegisterFormState();
  }
}

class _RegisterFormState extends ConsumerState<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final fullNameController = TextEditingController(text: '');
  final emailController = TextEditingController(text: '');
  final pwController = TextEditingController(text: '');
  final textStyle = const TextStyle(color: Colors.black, fontSize: 16);
  final errorStyle = const TextStyle(color: Colors.red, fontSize: 16);
  bool _isLoading = false;
  bool _obscureText = true;
  var emailCheck = (email) => email.endsWith('@mail.unej.ac.id');

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future<bool> registerOauth() async {
    try {
      final (isSucces, content) = await _authService.signInGoogle();
      setState(() {
        _isLoading = true;
      });

      if (isSucces) {
        if (content != null && mounted) {
          print("Token: $content");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Register berhasil")));
          var (result, kode) = await _authService.checkAuth(ref);
          if (!result) {
            if (mounted) {
              _authService.HandleError(kode);
            }
          } else {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()),
              );
            }
          }
        }
        return true;
      } else {
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

  Future<bool> registerEmail(
    String email,
    String fullName,
    String password,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final (isSucces, content) = await _authService.signUpEmail(
        email,
        fullName,
        password,
      );
      print("Status: $isSucces Content: $content");
      if (isSucces) {
        if (content != null && mounted) {
          var (result, kode) = await _authService.checkAuth(ref);
          if (!result) {
            if (mounted) {
              _authService.HandleError(kode);
            }
          } else {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DashboardPage()),
              );
            }
          }
        }
        return true;
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Register Gagal")));
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
    return SafeArea(
      child: Center(
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
                      const Text(
                        "Buat Akun",
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: 2,
                        style: TextStyle(color: Colors.black, fontSize: 26),
                      ),
                      const Text(
                        "Buat akun mahasiswa untuk mulai memberikan aspirasi.",
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: 2,
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: textStyle,
                        decoration: InputDecoration(
                          hintStyle: textStyle,
                          labelStyle: textStyle,
                          labelText: 'Nama Lengkap',
                          hintText: 'Username',
                          errorStyle: errorStyle,
                          border: OutlineInputBorder(),
                          // suffixIcon: Icon(Icons.error),
                        ),
                        controller: fullNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan nama lengkap';
                          }
                          return null;
                        },
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
                            return 'Pastikan email Unej';
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
                      buildRequirement(
                        pwController.text.length >= 8,
                        'Minimal 8 karakter',
                      ),

                      buildRequirement(
                        RegExp(r'[A-Z]').hasMatch(pwController.text),
                        'Memiliki huruf besar (A-Z)',
                      ),

                      buildRequirement(
                        RegExp(r'[a-z]').hasMatch(pwController.text),
                        'Memiliki huruf kecil (a-z)',
                      ),

                      buildRequirement(
                        RegExp(r'[0-9]').hasMatch(pwController.text),
                        'Memiliki angka (0-9)',
                      ),

                      buildRequirement(
                        RegExp(r'[!@#\$&*~]').hasMatch(pwController.text),
                        'Memiliki karakter spesial (!@#\$&*~)',
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);

                            final res = await registerEmail(
                              emailController.text,
                              fullNameController.text,
                              pwController.text,
                            );
                            if (res) {}
                            setState(() => _isLoading = false);
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
                                "Registrasi",
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
                          await registerOauth();
                        },
                        icon: Image.asset(
                          'assets/images/icons/google.png',
                          height: 26,
                        ),
                        label: const Text(
                          'Registrasi dengan Akun Google',
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
                                      builder: (_) => LoginPage(),
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
