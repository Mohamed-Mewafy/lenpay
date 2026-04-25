import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lenpay/l10n/app_localizations.dart';
import 'package:lenpay/data/firebase_service.dart';
import 'package:lenpay/main.dart';
import 'package:lenpay/ui/auth/login.dart';
import 'package:lenpay/ui/submain_page/edit_profile.dart';
import 'package:lenpay/util/route_transitions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _notifications = true;
  bool _biometrics = false;
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _loadLocalImage();
  }

  Future<void> _loadLocalImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    if (mounted) {
      setState(() => _localImagePath = path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings'.tr(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          const SizedBox(height: 10),
          // 1. Live Profile Header from Firestore
          StreamBuilder<DocumentSnapshot>(
            stream: _firebaseService.getUserStream(),
            builder: (context, snapshot) {
              String name = "User";
              String email = "";
              if (snapshot.hasError) {
                name = FirebaseAuth.instance.currentUser?.displayName ?? "User";
                email = FirebaseAuth.instance.currentUser?.email ?? "";
              } else if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                name = data['name'] ?? "User";
                email =
                    data['email'] ??
                    FirebaseAuth.instance.currentUser?.email ??
                    "";
              }
              return _buildProfileHeader(
                isDark,
                name: name,
                email: email,
                localImagePath: _localImagePath,
              );
            },
          ),

          const SizedBox(height: 30),

          _buildCategoryHeader('Account'.tr(context)),
          _buildSettingsTile(
            context,
            title: 'Edit Profile'.tr(context),
            icon: Icons.person_outline_rounded,
            color: Colors.blue,
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              AppRoutes.slideUp(page: const EditProfile()),
            ),
          ),
          _buildSettingsTile(
            context,
            title: 'Security & Privacy'.tr(context),
            icon: Icons.shield_outlined,
            color: Colors.green,
            isDark: isDark,
          ),

          const SizedBox(height: 25),

          _buildCategoryHeader('Application'.tr(context)),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, child) {
              final bool isDarkTheme = currentMode == ThemeMode.dark;
              return _buildToggleTile(
                'Dark Mode'.tr(context),
                Icons.dark_mode_outlined,
                Colors.purple,
                isDark,
                isDarkTheme,
                onChanged: (value) async {
                  themeNotifier.value = value
                      ? ThemeMode.dark
                      : ThemeMode.light;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('themeMode', value ? 'dark' : 'light');
                },
              );
            },
          ),
          _buildSettingsTile(
            context,
            title: 'Language'.tr(context),
            icon: Icons.language,
            color: Colors.blueAccent,
            isDark: isDark,
            onTap: () async {
              await AppLocalizations.toggleLocale();
              setState(() {});
            },
          ),
          _buildToggleTile(
            'Notifications'.tr(context),
            Icons.notifications_outlined,
            Colors.orange,
            isDark,
            _notifications,
            onChanged: (value) => setState(() => _notifications = value),
          ),
          _buildToggleTile(
            'Biometric Login'.tr(context),
            Icons.fingerprint_rounded,
            Colors.teal,
            isDark,
            _biometrics,
            onChanged: (value) => setState(() => _biometrics = value),
          ),

          const SizedBox(height: 25),

          _buildCategoryHeader('Support'.tr(context)),
          _buildSettingsTile(
            context,
            title: 'Help Center'.tr(context),
            icon: Icons.help_outline_rounded,
            color: Colors.blueGrey,
            isDark: isDark,
          ),
          _buildSettingsTile(
            context,
            title: 'About LenPay'.tr(context),
            icon: Icons.info_outline_rounded,
            color: Colors.indigo,
            isDark: isDark,
          ),

          const SizedBox(height: 40),

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: OutlinedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  AppRoutes.fade(page: const Login()),
                  (route) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Logout Account'.tr(context),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    bool isDark, {
    required String name,
    required String email,
    String? localImagePath,
  }) {
    ImageProvider profileImage = Image.asset("assets/images/user.png").image;
    if (localImagePath != null) {
      final file = File(localImagePath);
      if (file.existsSync()) {
        profileImage = FileImage(file);
      } else {
        // Stale path — clear it asynchronously
        SharedPreferences.getInstance().then((prefs) {
          prefs.remove('profile_image_path');
        });
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent, width: 2),
            ),
            child: CircleAvatar(radius: 35, backgroundImage: profileImage),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              AppRoutes.slideUp(page: const EditProfile()),
            ),
            icon: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  Widget _buildToggleTile(
    String title,
    IconData icon,
    Color color,
    bool isDark,
    bool value, {
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.blueAccent,
        activeTrackColor: Colors.blueAccent.withValues(alpha: 0.5),
      ),
    );
  }
}
