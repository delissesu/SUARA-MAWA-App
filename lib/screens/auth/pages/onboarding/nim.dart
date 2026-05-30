import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';
import 'package:suara_mawa/screens/auth/controller/onboarding.dart';
import 'package:suara_mawa/screens/auth/index.dart';
import 'package:suara_mawa/screens/auth/pages/onboarding/email_verification.dart';
import 'package:suara_mawa/utils/app_colors.dart';
import 'package:suara_mawa/screens/auth/components/progress_indicator.dart';

class NimForm extends StatefulWidget {
  const NimForm({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NimFormState();
  }
}

class _NimFormState extends State<NimForm> {
  late String email;
  final _authService = AuthService();
  bool _wait = true;
  bool _isLoading = false;
  bool _nimFilled = false;
  final nimController = TextEditingController(text: '');
  final textStyle = const TextStyle(color: Colors.black, fontSize: 16);
  @override
  void initState() {
    super.initState();
    // Move your logic here
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await _authService.getUser();
    final detail = await _authService.getMahasiswaDetail();
    print(user);
    setState(() {
      email = user?.email ?? 'Not found';
      _nimFilled = detail != null;
      _wait = false;
    });
  }

  Future<bool> _handleAppendNIM() async {
    if (_nimFilled) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PhonePage()),
      );
      return true;
    } else {
      setState(() {
        _isLoading = true;
      });
      var (isSucces, content) = await _authService.appendNIM(
        nimController.text,
      );
      print('IsSuccess: $isSucces');
      if (isSucces) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PhonePage()),
        );
        setState(() {
          _isLoading = false;
        });
        return true;
      } else {
        setState(() {
          _isLoading = false;
        });
        return false;
      }
    }
    ;
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
        : SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                const SizedBox(height: 60),
                StepProgressView(
                  width: MediaQuery.of(context).size.width,
                  currentStep: 2,
                  activeColor: AppColors.primary,
                  titles: Onboarding.stepNames,
                ),
                const SizedBox(height: 80),
                const Text(
                  "Isi NIM Anda",
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                  style: TextStyle(color: Colors.black, fontSize: 26),
                ),
                TextFormField(
                  style: textStyle,
                  decoration: InputDecoration(
                    hintStyle: textStyle,
                    hintText: 'Password',
                    labelStyle: textStyle,
                    labelText: 'Password',
                    errorStyle: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
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
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _handleAppendNIM,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _nimFilled
                        ? Colors.green
                        : AppColors.primary,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        )
                      : (_nimFilled
                            ? const Text(
                                "Update NIM",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                ),
                              )
                            : const Text(
                                "Tambahkan NIM",
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                ),
                              )),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VerifyEmailPage(),
                      ),
                    );
                  },
                  child: Text("Kembali"),
                ),
              ],
            ),
          );
  }
}
