import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lenpay/l10n/app_localizations.dart';
import 'package:lenpay/ui/auth/login.dart';
import 'package:lenpay/ui/navbar/navbar.dart';
import 'package:lenpay/util/route_transitions.dart';
import 'package:lenpay/widget/custom_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  final String? password;
  final String? name;

  const EmailVerificationPage({
    super.key,
    required this.email,
    this.password,
    this.name,
  });

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isVerifying = false;
  bool _isResending = false;
  bool _isVerified = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  final _generateOTP = FirebaseFunctions.instance.httpsCallable(
    'generateEmailOTP',
  );
  final _verifyOTP = FirebaseFunctions.instance.httpsCallable('verifyEmailOTP');

  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _sendOTP() async {
    setState(() => _isResending = true);

    try {
      await _generateOTP.call({
        'email': widget.email,
        'name': widget.name ?? 'User',
      });

      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: 'Verification code sent to your email.'.tr(context),
        type: SnackbarType.success,
      );
      _startResendCooldown();
    } on FirebaseFunctionsException catch (e) {
      String message = e.message ?? 'Failed to send code';
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: message,
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Error: ${e.toString()}',
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown <= 1) {
        timer.cancel();
      }
      if (mounted) {
        setState(() => _resendCooldown--);
      }
    });
  }

  String get _otpCode {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _verifyCode() async {
    final code = _otpCode;
    if (code.length != 6) {
      CustomSnackbar.show(
        context,
        message: 'Please enter the 6-digit code'.tr(context),
        type: SnackbarType.info,
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      await _verifyOTP.call({'email': widget.email, 'otp': code});

      if (!mounted) return;

      // Reload user to update local emailVerified status
      await FirebaseAuth.instance.currentUser?.reload();

      // Ensure the user is still signed in after reload
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        CustomSnackbar.show(
          context,
          
          message: 'Session expired. Please log in again.'.tr(context),
          type: SnackbarType.error,
        );
        await _signOutAndGoToLogin();
        return;
      }

      setState(() => _isVerified = true);
      await _onVerified();
    } on FirebaseFunctionsException catch (e) {
      String message = e.message ?? 'Invalid code';
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: message,
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Error: ${e.toString()}',
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _onVerified() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    if (!mounted) return;
    CustomSnackbar.show(
      context,
      message: 'Email verified successfully!'.tr(context),
      type: SnackbarType.success,
    );

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      AppRoutes.fade(page: const MainNavigation()),
      (route) => false,
    );
  }

  void _onOtpChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }

    // Auto-verify when all 6 digits are entered
    if (_otpCode.length == 6) {
      _verifyCode();
    }
  }

  Future<void> _signOutAndGoToLogin() async {
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      AppRoutes.fade(page: const Login()),
      (route) => false,
    );
  }
@override
Widget build(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;

  return Scaffold( // الـ Scaffold هو الأساس
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        TextButton(
          onPressed: _signOutAndGoToLogin,
          child: Text(
            'Sign Out'.tr(context),
            style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ],
    ),
    body: SafeArea(
      child: SingleChildScrollView( // الـ Scroll يكون جوه الـ body عشان لو الكيبورد فتحت
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Email Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isVerified
                      ? Icons.check_circle_outline
                      : Icons.mark_email_unread_outlined,
                  size: 64,
                  color: _isVerified ? Colors.green : Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 30),
            
              // Title
              Text(
                _isVerified
                    ? 'Email Verified!'.tr(context)
                    : 'Verify Your Email'.tr(context),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            
              // Description
              Text(
                _isVerified
                    ? 'Your email has been verified successfully. Redirecting...'
                          .tr(context)
                    : 'Enter the 6-digit code sent to'.tr(context),
                style: const TextStyle(color: Colors.grey, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              if (!_isVerified) ...[
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            
              const SizedBox(height: 40),
            
              if (_isVerified) ...[
                const Center(child: CircularProgressIndicator(color: Colors.green)),
              ] else ...[
                // OTP Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 42, // قللت العرض شوية عشان يظبط في الشاشات الصغيرة
                      height: 56,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1C1F2E)
                            : Colors.grey.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _otpFocusNodes[index].hasFocus
                              ? Colors.blueAccent
                              : (isDark
                                    ? Colors.white10
                                    : Colors.black.withValues(alpha: 0.05)),
                        ),
                      ),
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _otpFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onOtpChanged(index, value),
                      ),
                    );
                  }),
                ),
            
                const SizedBox(height: 30),
            
                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Verify'.tr(context),
                            style: const TextStyle(fontSize: 17),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
            
                // Resend Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: (_isResending || _resendCooldown > 0)
                        ? null
                        : _sendOTP,
                    icon: _isResending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.blueAccent,
                            ),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(
                      _resendCooldown > 0
                          ? AppLocalizations.translateFormat(
                              context,
                              'Resend in {seconds}s',
                              {'seconds': '$_resendCooldown'},
                            )
                          : 'Resend Code'.tr(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      side: const BorderSide(color: Colors.blueAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
            
                // Back to Login
                TextButton(
                  onPressed: _signOutAndGoToLogin,
                  child: Text(
                    'Back to Sign In'.tr(context),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}}