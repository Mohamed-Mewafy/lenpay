import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lenpay/l10n/app_localizations.dart';
import 'package:lenpay/data/firebase_service.dart';
import 'package:lenpay/widget/custom_snackbar.dart';
import 'package:lenpay/widget/interactive_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isLoading = false;
  bool _isDataLoading = true;
  final String? _profileImageUrl = "https://i.pravatar.cc/150?u=lenpay";
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _firebaseService.getUserData();
    final prefs = await SharedPreferences.getInstance();
    final savedPath = prefs.getString('profile_image_path');
    if (mounted) {
      setState(() {
        if (data != null) {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _locationController.text = data['location'] ?? '';
        }
        _localImagePath = savedPath;
        _isDataLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      await _firebaseService.updateUserProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
      );
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: 'Profile updated successfully!'.tr(context),
        type: SnackbarType.success,
      );
      Navigator.pop(context);
    } catch (e) {
      CustomSnackbar.show(
        context,
        message: AppLocalizations.translateFormat(
          context,
          'Failed to update: {error}',
          {'error': e.toString()},
        ),
        type: SnackbarType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedFile == null) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_path', pickedFile.path);

      if (!mounted) return;
      setState(() {
        _localImagePath = pickedFile.path;
      });
      CustomSnackbar.show(
        context,
        message: 'Profile photo updated!'.tr(context),
        type: SnackbarType.success,
      );
    } catch (e) {
      CustomSnackbar.show(
        context,
        message: 'Error: ${e.toString()}',
        type: SnackbarType.error,
      );
    }
  }

  Future<void> _removePhoto() async {
    Navigator.pop(context);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image_path');
    if (!mounted) return;
    setState(() {
      _localImagePath = null;
    });
    CustomSnackbar.show(
      context,
      message: 'Profile photo removed!'.tr(context),
      type: SnackbarType.success,
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Profile Photo'.tr(context),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildOption(
                icon: Icons.camera_alt_rounded,
                label: 'Take Photo'.tr(context),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              _buildOption(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery'.tr(context),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              _buildOption(
                icon: Icons.delete_forever_rounded,
                label: 'Remove Photo'.tr(context),
                color: Colors.redAccent,
                onTap: _removePhoto,
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (color ?? Colors.blueAccent).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color ?? Colors.blueAccent, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
      onTap: onTap,
    );
  }

  Future<ImageProvider?> _getProfileImage() async {
    if (_localImagePath != null) {
      final file = File(_localImagePath!);
      if (await file.exists()) {
        return FileImage(file);
      }
      // Stale path — clear it
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_image_path');
      if (mounted) setState(() => _localImagePath = null);
    }
    if (_profileImageUrl != null) {
      return NetworkImage(_profileImageUrl);
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile'.tr(context),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isDataLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  // Profile Picture
                  Center(
                    child: GestureDetector(
                      onTap: () => _showImageSourceActionSheet(context),
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blueAccent,
                                width: 2,
                              ),
                            ),
                            child: FutureBuilder<ImageProvider?>(
                              future: _getProfileImage(),
                              builder: (context, snap) {
                                return CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.blueAccent.withValues(
                                    alpha: 0.1,
                                  ),
                                  backgroundImage: snap.data,
                                  child: snap.data == null
                                      ? const Icon(
                                          Icons.person_rounded,
                                          size: 50,
                                          color: Colors.blueAccent,
                                        )
                                      : null,
                                );
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildEditField(
                    label: 'Full Name'.tr(context),
                    controller: _nameController,
                    icon: Icons.person_outline_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  _buildEditField(
                    label: 'Email Address'.tr(context),
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    isDark: isDark,
                    enabled: false,
                  ),
                  const SizedBox(height: 20),
                  _buildEditField(
                    label: 'Phone Number'.tr(context),
                    controller: _phoneController,
                    icon: Icons.phone_outlined,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  _buildEditField(
                    label: 'Location'.tr(context),
                    controller: _locationController,
                    icon: Icons.location_on_outlined,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 40),
                  InteractiveButton(
                    text: 'Save Changes'.tr(context),
                    isLoading: _isLoading,
                    onPressed: _saveProfile,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isDark,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1F2E)
                : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: enabled ? null : Colors.grey,
            ),
            decoration: InputDecoration(
              icon: Icon(icon, color: Colors.blueAccent, size: 20),
              border: InputBorder.none,
              hintText: AppLocalizations.translateFormat(
                context,
                'Enter {label}',
                {'label': label},
              ),
            ),
          ),
        ),
      ],
    );
  }
}
