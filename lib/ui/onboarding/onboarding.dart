import 'package:flutter/material.dart';
import 'package:lenpay/l10n/app_localizations.dart';
import 'package:lenpay/ui/auth/login.dart';

import 'package:shared_preferences/shared_preferences.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Illustration / Image Mockup
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                      : [Colors.blueAccent, Colors.blue.shade900],
                ),
              ),
              child: Opacity(
                opacity: 0.1,
                child: Center(
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 300,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),

          // 2. Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const SizedBox(height: 20),
                  // Premium Typography
                  Text(
                    'Welcome to\nLenPay Wallet'.tr(context),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'The most secure and easy way to manage your finances, pay bills, and transfer money instantly.'
                        .tr(context),
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Get Started Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Mark onboarding as completed
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('isFirstTime', false);

                        if (!context.mounted) return;

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Get Started'.tr(context),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
