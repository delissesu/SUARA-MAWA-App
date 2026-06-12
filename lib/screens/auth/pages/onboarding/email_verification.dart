import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';
import 'package:suara_mawa/screens/auth/controller/onboarding.dart';
import 'package:suara_mawa/screens/auth/index.dart';
import 'package:suara_mawa/utils/app_colors.dart';
import 'package:suara_mawa/screens/auth/components/progress_indicator.dart';

class EmailVerification extends ConsumerStatefulWidget {
  const EmailVerification({super.key});

  @override
  ConsumerState<EmailVerification> createState() {
    return _EmailVerificationState();
  }
}

class _EmailVerificationState extends ConsumerState<EmailVerification> {
  String? email = "";
  late String? password;
  final _authService = AuthService();
  bool _isLoading = true;
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
        _isLoading = false;
      });
    } else {
      var (x, y) = await _authService.getEmailPw();
      setState(() {
        email = x;
        password = y;
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
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
          });
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Column(
            children: [
              // ======================
              // FIXED PROGRESS BAR
              // ======================
              Padding(
                padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
                child: StepProgressView(
                  width: MediaQuery.of(context).size.width,
                  currentStep: 1,
                  activeColor: AppColors.primary,
                  titles: Onboarding.stepNames,
                ),
              ),

              // ======================
              // SCROLLABLE CONTENT
              // ======================
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 40,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 10,
                      children: [
                        const SizedBox(height: 20),
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
                            await _authService.logout(ref);
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
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          const Opacity(
            opacity: 0.6,
            child: ModalBarrier(dismissible: false, color: Colors.black),
          ),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    ); 
  }
}
