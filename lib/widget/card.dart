import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lenpay/main.dart';
import 'package:lenpay/data/firebase_service.dart';
import 'package:lenpay/ui/submain_page/recharge_wallet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardBank extends StatefulWidget {
  const CardBank({super.key});

  @override
  State<CardBank> createState() => _CardBankState();
}

class _CardBankState extends State<CardBank> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<DocumentSnapshot>(
      stream: _firebaseService.getUserStream(),
      builder: (context, snapshot) {
        double balance = 0.0;
        String name = "GUEST USER";

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          balance = (data['balance'] ?? 0.0).toDouble();
          name = (data['name'] ?? "GUEST USER").toUpperCase();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 230,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. The Main Premium Card
                  Container(
                    width: 350,
                    height: 200,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                const Color(0xFF1A237E), // Deep Indigo
                                const Color(0xFF4A148C), // Deep Purple
                                const Color(0xFF6A1B9A), // Purple
                              ]
                            : [
                                const Color(0xFF1E88E5), // Bright Blue
                                const Color(0xFF1565C0), // Median Blue
                                const Color(0xFF0D47A1), // Deep Navy
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.purple : Colors.blue)
                              .withValues(alpha: 0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top: Logo and Chip
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.contactless_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            _buildCardLogo(),
                          ],
                        ),

                        // Middle: Balance (Glassmorphic look)
                        ValueListenableBuilder<bool>(
                          valueListenable: balanceVisibilityNotifier,
                          builder: (context, isVisible, child) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      transitionBuilder: (child, animation) =>
                                          FadeTransition(
                                              opacity: animation, child: child),
                                      child: Text(
                                        isVisible
                                            ? "\$ ${NumberFormat("#,##0.00", "en_US").format(balance)}"
                                            : "*******",
                                        key: ValueKey<bool>(isVisible),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () async {
                                      balanceVisibilityNotifier.value = !isVisible;
                                      final SharedPreferences prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.setBool(
                                          'balanceVisibility', !isVisible);
                                    },
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 300),
                                      child: Icon(
                                        isVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        key: ValueKey<bool>(isVisible),
                                        color: Colors.white.withValues(alpha: 0.8),
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        // Bottom: Info (Number & Name)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "**** **** **** 4251",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 13,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "09/28",
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 2. Recharge Button (Floating Style)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _buildAnimatedRechargeButton(context, isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedRechargeButton(BuildContext context, bool isDark) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RechargeWallet(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2ECC71) : const Color(0xFF27AE60),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Recharge",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardLogo() {
    return Stack(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.8),
            shape: BoxShape.circle,
          ),
        ),
        Positioned(
          left: 15,
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
