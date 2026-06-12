import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';
import 'package:suara_mawa/screens/auth/controller/onboarding.dart';
import 'package:suara_mawa/screens/auth/index.dart';
import 'package:suara_mawa/utils/app_colors.dart';
import 'package:suara_mawa/screens/auth/components/progress_indicator.dart';

class PhoneNumber extends StatefulWidget {
  const PhoneNumber({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PhoneNumberState();
  }
}

class _PhoneNumberState extends State<PhoneNumber> {
  final _authService = AuthService();
  bool _isLoading = true;
  final nomorHPController = TextEditingController(text: '');
  final textStyle = const TextStyle(color: Colors.black, fontSize: 16);
  final errorStyle = const TextStyle(color: Colors.red, fontSize: 16);
  bool _isFilled = false;
  final idPhoneRegex = RegExp(r'^(\+62|62|0)8[1-9][0-9]{7,11}$');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _authService.getUser();
    print(user);

    if (user != null) {
      if (user.phoneNumber != null) {
        setState(() {
          _isFilled = true;
          nomorHPController.text = user.phoneNumber!;
        });
      } else {
        setState(() {
          _isFilled = false;
        });
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
                  currentStep: 3,
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 10,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        "Nomor Telepon",
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: 2,
                        style: TextStyle(color: Colors.black, fontSize: 26),
                      ),
                      const Text(
                        "Silakan isi nomor telepon akun anda",
                        textAlign: TextAlign.center,
                        softWrap: true,
                        maxLines: 2,
                        style: TextStyle(color: Colors.black, fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style: textStyle,
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            if (RegExp(r'^\+?[0-9]*$').hasMatch(newValue.text)) {
                              return newValue;
                            }
                            return oldValue;
                          }),
                        ],
                        decoration: InputDecoration(
                          hintStyle: textStyle,
                          hintText: 'Nomor Telepon',
                          labelStyle: textStyle,
                          labelText: 'Nomor telepon',
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
                      const SizedBox(height: 20),
                      if (_isFilled)
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PhonePage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size(double.infinity, 44),
                          ),
                          child: const Text(
                            "Selanjutnya",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            _isLoading = true;
                          });
                          var (res, code) = await _authService.appendNomorHP(
                            nomorHPController.text,
                          );
                          if (res) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhoneVerifyPage(),
                              ),
                            );
                          } else {
                            _authService.HandleError(code ?? '');
                          }
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child: _isFilled
                            ? const Text(
                                "Update Nomor Telepon",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                ),
                              )
                            : const Text(
                                "Tambahkan Nomor Telepon",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => NimPage()),
                          );
                        },
                        child: Text("Kembali"),
                      ),
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
