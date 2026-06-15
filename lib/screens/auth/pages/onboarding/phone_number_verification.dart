import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:suara_mawa/screens/aspirasi/aspirasi_main_screen.dart';
import 'package:suara_mawa/screens/auth/components/progress_indicator.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';
import 'package:suara_mawa/screens/auth/controller/onboarding.dart';
import 'package:suara_mawa/screens/auth/index.dart';
import 'package:suara_mawa/utils/app_colors.dart';

class PhoneNumberVerification extends StatefulWidget {
  const PhoneNumberVerification({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PhoneNumberVerificationState();
  }
}

class _PhoneNumberVerificationState extends State<PhoneNumberVerification> {
  late String phoneNumber;
  String otp = "";
  final _authService = AuthService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    phoneNumber = "1231";
  }

  Future<void> _sendOTP() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var (isSuccess, content) = await _authService.askPhoneVerif();
      String msg = "";
      if (isSuccess) {
        msg = "OTP Terkirim";
      } else {
        msg = "Error: $content";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
                  currentStep: 4,
                  activeColor: AppColors.primary,
                  titles: Onboarding.stepNames,
                ),
              ),

              // ======================
              // SCROLLABLE CONTENT
              // ======================
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      const Text(
                        "Verifikasi Nomor Telepon Anda",
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: 2,
                        style: TextStyle(color: Colors.black, fontSize: 26),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        "Silakan cek WhatsApp yang kami kirim pada nomor $phoneNumber",
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 40),
                      PinCodeTextField(
                        appContext: context,

                        length: 6,

                        keyboardType: TextInputType.number,

                        autoFocus: true,

                        animationType: AnimationType.fade,

                        enableActiveFill: true,

                        cursorColor: Colors.black,

                        pastedTextStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),

                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),

                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,

                          borderRadius: BorderRadius.circular(12),

                          fieldHeight: 50,
                          fieldWidth: 40,

                          activeFillColor: Colors.white,
                          selectedFillColor: Colors.white,
                          inactiveFillColor: Colors.white,

                          activeColor: Colors.black,
                          selectedColor: Colors.blue,
                          inactiveColor: Colors.grey.shade400,
                        ),

                        onChanged: (value) {
                          otp = value;
                        },

                        onCompleted: (value) async {
                          print("OTP: $value");
                          var (isSucces, content) = await _authService
                              .verifyPhone(value);
                          print("Result: $isSucces Content: $content");
                          if (isSucces) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AspirasiMainScreen(),
                              ),
                            );
                            setState(() {
                              _isLoading = false;
                            });
                          } else {
                            setState(() {
                              _isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Gagal, pesan: $content")),
                            );
                          }
                          // verify OTP ke server
                          // await api.verifyOTP(value);
                        },
                      ),
                      const SizedBox(height: 20),

                      // ======================
                      // RESEND LINK
                      // ======================
                      Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : GestureDetector(
                                onTap: _sendOTP,
                                child: const Text(
                                  "Kirim ulang kode verifikasi",
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                      ),

                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhonePage(),
                            ),
                          );
                        },

                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                        ),

                        child: const Text("Kembali"),
                      ),

                      const SizedBox(height: 32),
                    ],
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
