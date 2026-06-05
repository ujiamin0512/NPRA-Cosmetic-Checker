import 'package:flutter/material.dart';

import '../databases/user_db.dart';
import '../models/userinput.dart';
import '../widgets/inputfield.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = await UserDatabase.getCurrentUser();
    if (mounted && user != null) {
      setState(() {
        _nameController.text = user.username;
        _emailController.text = user.email;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Update your personal details below.',
            style: TextStyle(
              color: Color(0xFF333752),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          InputField(
            controller: _nameController,
            spec: InputFieldSpec.username,
          ),
          const SizedBox(height: 20),
          InputField(
            controller: _emailController,
            spec: InputFieldSpec.email,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1D0CC2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              onPressed: _saving ? null : _handleSave,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    final String username = _nameController.text.trim();
    final String email = _emailController.text.trim();

    if (username.isEmpty && email.isEmpty) {
      _showSnackBar('Please enter your name or email');
      return;
    }

    setState(() => _saving = true);

    try {
      final int updated = await UserDatabase.updateProfile(
        username: username.isNotEmpty ? username : null,
        email: email.isNotEmpty ? email : null,
      );

      if (!mounted) return;

      if (updated == 0) {
        _showSnackBar('Please log in before updating your profile');
        return;
      }

      _showSnackBar('Profile updated');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}