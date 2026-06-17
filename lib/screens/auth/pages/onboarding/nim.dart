import 'package:flutter/material.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';
import 'package:suara_mawa/screens/auth/controller/onboarding.dart';
import 'package:suara_mawa/screens/auth/index.dart';
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
  bool _isLoading = true;
  bool _nimFilled = false;
  final textController = TextEditingController(text: '');
  final textStyle = const TextStyle(color: Colors.black, fontSize: 16);
  bool _isMahasiswa = true;
  @override
  void initState() {
    super.initState();
    // Move your logic here
    _loadData();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = await _authService.getUser();
    _isMahasiswa = user?.userRole?.name == "MAHASISWA";
    final res = (await _authService.getDetail(isMahasiswa: _isMahasiswa));

    final isFilled = res != null;
    if (isFilled) {
      if (_isMahasiswa) {
        setState(() {
          textController.text = res['nim'];
        });
      } else {
        setState(() {
          textController.text = res['nik'];
        });
      }
    }
    setState(() {
      email = user?.email ?? 'Not found';
      _nimFilled = isFilled;
      _isLoading = false;
    });
  }

  Future<bool> _handleAppendNIM() async {
    setState(() {
      _isLoading = true;
    });
    var (isSucces, content) = await _authService.appendNIM(
      textController.text,
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
                  currentStep: 2,
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
                          hintText: _isMahasiswa ? 'NIM' : "NIK",
                          labelStyle: textStyle,
                          labelText: _isMahasiswa ? 'NIM' : "NIK",
                          errorStyle: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                        ),
                        controller: textController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _isMahasiswa ? 'Masukkan NIM' : 'Masukkan NIK';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_nimFilled)
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
                        onPressed: _handleAppendNIM,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child: (_nimFilled
                            ? Text(
                                _isMahasiswa ? "Update NIM" : 'Update NIK',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                ),
                              )
                            : Text(
                                _isMahasiswa ? "Tambahkan NIM" : 'Tambahkan NIK',
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
