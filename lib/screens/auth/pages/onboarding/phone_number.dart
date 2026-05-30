import 'package:flutter/material.dart';
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
  bool _isLoading = false;
  final nomorHPController = TextEditingController(text: '');
  final textStyle = const TextStyle(color: Colors.black, fontSize: 16);
  final errorStyle = const TextStyle(color: Colors.red, fontSize: 16);

  @override
  void initState() {
    super.initState();
    // Move your logic here
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 10,
      children: [
        const SizedBox(height: 60),
        StepProgressView(
          width: MediaQuery.of(context).size.width,
          currentStep: 3,
          activeColor: AppColors.primary,
          titles: Onboarding.stepNames,
        ),
        const SizedBox(height: 80),
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
          decoration: InputDecoration(
            hintStyle: textStyle,
            hintText: 'Nomor Telepon',
            labelStyle: textStyle,
            labelText: 'Nomor telepon',
            errorStyle: errorStyle,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2.0),
            ),
          ),
          controller: nomorHPController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Masukkan email';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
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
                MaterialPageRoute(builder: (context) => PhoneVerifyPage()),
              );
            } else {
              _authService.HandleError(code ?? '', context);
            }
            setState(() {
              _isLoading = false;
            });
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
                  "Tambahkan Nomor Telepon",
                  style: TextStyle(color: AppColors.white, fontSize: 16),
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
    );
  }
}
