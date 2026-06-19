import 'package:flutter/material.dart';

const kNavy = Color(0xFF1A2C5B);
const kTeal = Color(0xFF4DD0C4);
const kBg   = Color(0xFFF5F6FA);

class LoadingPage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry; 
  
  const LoadingPage({
    super.key, 
    this.message = 'Mohon tunggu sebentar...',
    this.onRetry, 
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Container(
                  width: 120, 
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8ECF5), 
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 70,
                        height: 70,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(kTeal),
                          strokeWidth: 4, 
                        ),
                      ),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 28),
                const Text(
                  'Sedang Memuat',
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.w800, 
                    color: kNavy,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13, 
                    color: Colors.grey.shade500, 
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 80), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}