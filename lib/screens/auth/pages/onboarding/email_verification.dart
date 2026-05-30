import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';
import 'package:suara_mawa/screens/auth/controller/onboarding.dart';
import 'package:suara_mawa/screens/auth/index.dart';
import 'package:suara_mawa/utils/app_colors.dart';
import 'package:suara_mawa/screens/auth/components/progress_indicator.dart';

class EmailVerification extends StatefulWidget {
  const EmailVerification({super.key});

  @override
  State<StatefulWidget> createState() {
    return _EmailVerificationState();
  }
}

class _EmailVerificationState extends State<EmailVerification> {
  late String? email;
  late String? password;
  final _authService = AuthService();
  bool _wait = true;
  bool _isLoading = false;
  bool _isVerified = false;
  @override
  void initState() {
    super.initState();
    // Move your logic here
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _authService.getUser();
    print(user);

    if (user != null) {
      setState(() {
        email = user.email;
        _isVerified = user.emailVerified;
        _wait = false;
      });
    } else {
      var (x, y) = await _authService.getEmailPw();
      setState(() {
        email = x;
        password = y;
        _wait = false;
      });
    }
    ;
  }

  Future<void> _onRefresh() async {
    setState(() {
      _wait = true;
    });
    final user = await _authService.getUser();
    if (user != null) {
      var (retrivedEmail, retrievedPassword) = await _authService.getEmailPw();
      if (retrivedEmail != null) {
        final (isSucces, content) = await _authService.signInEmail(
          retrivedEmail,
          retrievedPassword!,
        );
        if (isSucces) {
          setState(() {
            _isVerified = true;
            _wait = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _wait
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 2,
            ),
          )
        : RefreshIndicator(
            onRefresh: _onRefresh,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                const SizedBox(height: 60),
                StepProgressView(
                  width: MediaQuery.of(context).size.width,
                  currentStep: 1,
                  activeColor: AppColors.primary,
                  titles: Onboarding.stepNames,
                ),
                const SizedBox(height: 80),
                const Text(
                  "Verifikasi Email Anda",
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                  style: TextStyle(color: Colors.black, fontSize: 26),
                ),
                Text(
                  "Silakan cek email yang masuk pada akun $email",
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_isVerified) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NimPage(),
                        ),
                      );
                    } else {
                      setState(() {
                        _isLoading = true;
                      });
                      await _authService.askEmailVerif(email!, password!);
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isVerified
                        ? Colors.green
                        : AppColors.primary,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        )
                      : (_isVerified
                            ? const Text(
                                "Sudah verifikasi",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                ),
                              )
                            : const Text(
                                "Kirim ulang email verifikasi",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                ),
                              )),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _authService.logout();
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    }
                  },
                  child: Text("Kembali"),
                ),
              ],
            ),
          );
  }
}
