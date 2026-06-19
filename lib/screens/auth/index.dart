import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suara_mawa/screens/auth/controller/auth_service.dart';
import 'package:suara_mawa/screens/auth/pages/login.dart';
import 'package:suara_mawa/screens/auth/pages/onboarding/email_verification.dart';
import 'package:suara_mawa/screens/auth/pages/onboarding/nim.dart';
import 'package:suara_mawa/screens/auth/pages/onboarding/phone_number.dart';
import 'package:suara_mawa/screens/auth/pages/onboarding/phone_number_verification.dart';
import 'package:suara_mawa/screens/auth/pages/register.dart';
import 'package:suara_mawa/screens/profile/index.dart';
import 'package:suara_mawa/utils/user_controller.dart';

class FirstPage extends ConsumerStatefulWidget {
  const FirstPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _FirstPageState();
  }
}

class _FirstPageState extends ConsumerState<FirstPage> {
  final _authHandler = AuthService();

  Future<String> _check() async {
    var (res, code) = await _authHandler.checkAuth(ref);
    if (res) {
      return "SUCCESS";
    } else {
      return code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _check(), // The asynchronous operation
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              ),
            ),
          ); // 1. Still loading
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          ); // 2. Something went wrong
        } else {
          final code = snapshot.data ?? "DEFAULT";

          WidgetsBinding.instance.addPostFrameCallback((_) {
            print("Code First Page: $code");
            _authHandler.HandleError(code);
          });

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: LoginForm(),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:  RegisterForm(),
    );
  }
}

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: EmailVerification()));
  }
}

class NimPage extends StatelessWidget {
  const NimPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: const NimForm()));
  }
}

class PhonePage extends StatelessWidget {
  const PhonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: PhoneNumber()));
  }
}

class PhoneVerifyPage extends StatelessWidget {
  const PhoneVerifyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: PhoneNumberVerification()));
  }
}

class DashboardPage extends ConsumerWidget {
  DashboardPage({super.key});

  final _authService = AuthService();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModel = ref.watch(userControllerProvider);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsetsGeometry.symmetric(horizontal: 16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Dashboard"),
                ElevatedButton(
                  onPressed: () async {
                    _authService.logout(ref);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text("LogOut"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // _authService.logout(ref);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  },
                  child: const Text("Profile"),
                ),
                Text(userModel.user?.name ?? 'default')
              ],
            ),
          ),
        ),
      ),
    );
  }
}
