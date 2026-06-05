import 'package:flutter/material.dart';

import '../databases/user_db.dart';
import '../widgets/pin_input_field.dart';

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
            'Secure your account with a new 6-digit PIN.',
            style: TextStyle(
              color: Color(0xFF333752),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),
          PinInputField(
            controller: _oldPasswordController,
            label: 'Old 6-digit PIN',
          ),
          const SizedBox(height: 20),
          PinInputField(
            controller: _newPasswordController,
            label: 'New 6-digit PIN',
          ),
          const SizedBox(height: 20),
          PinInputField(
            controller: _confirmPasswordController,
            label: 'Confirm 6-digit PIN',
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
              onPressed: _saving ? null : _handleUpdate,
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
                      'Update',
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

  Future<void> _handleUpdate() async {
    final String oldPassword = _oldPasswordController.text;
    final String newPassword = _newPasswordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    if (newPassword.length != 6 || int.tryParse(newPassword) == null) {
      _showSnackBar('New PIN must be exactly 6 digits');
      return;
    }

    setState(() => _saving = true);

    try {
      final bool oldMatches = await _verifyOldPassword(oldPassword);
      if (!oldMatches) return;

      final bool newMatches = _newPasswordsMatch(newPassword, confirmPassword);
      if (!newMatches) return;

      final int updated = await UserDatabase.updatePassword(
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;

      if (updated == 0) {
        _showSnackBar('Please log in before updating your PIN');
        return;
      }

      _showSnackBar('PIN updated successfully');
      _clearFields();
      
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<bool> _verifyOldPassword(String oldPassword) async {
    final user = await UserDatabase.getCurrentUser();

    if (user == null) {
      _showSnackBar('Please log in to update your PIN');
      return false;
    }

    try {
      // Securely verify old PIN by attempting validation
      final validatedUser = await UserDatabase.validateCredentials(user.email, oldPassword);
      if (validatedUser == null) {
        _showSnackBar('Old PIN is incorrect');
        return false;
      }
    } catch (e) {
      _showSnackBar('Old PIN is incorrect');
      return false;
    }

    return true;
  }

  bool _newPasswordsMatch(String newPassword, String confirmPassword) {
    if (newPassword != confirmPassword) {
      _showSnackBar('New PINs do not match');
      return false;
    }
    return true;
  }

  void _clearFields() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}