import 'package:flutter/material.dart';

import '../databases/user_db.dart';
import '../models/user.dart';
import '../models/userinput.dart';
import '../widgets/inputfield.dart';
import '../widgets/pin_input_field.dart';
import '../widgets/logoheader.dart';
import 'dashboard.dart';
import 'signup_page.dart';
import 'skin_profile_wizard.dart';
class LoginPage extends StatelessWidget {
  final bool showBackButton;
  const LoginPage({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F5FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: showBackButton,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              LogoHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xFF1D0CC2),
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: Color(0xFF333752),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const SignUpPage()),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color(0xFF1D0CC2),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    /// Login Form
                    const _LoginForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[

        InputField(
          controller: _emailController,
          spec: InputFieldSpec.email,
        ),

        const SizedBox(height: 16),

        PinInputField(
          controller: _passwordController,
        ),

        const SizedBox(height: 28),

        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _submitting ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D0CC2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Log In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 52,
          child: OutlinedButton(
            onPressed: _submitting ? null : _handleGuestLogin,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1D0CC2), width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text(
              'Continue as Guest',
              style: TextStyle(
                color: Color(0xFF1D0CC2),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleGuestLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const Dashboard(isGuest: true),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _handleLogin() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter email and PIN');
      return;
    }

    if (password.length != 6 || int.tryParse(password) == null) {
      _showSnackBar('PIN must be exactly 6 digits');
      return;
    }
    setState(() => _submitting = true);

    try {
      final User? user =
          await UserDatabase.validateCredentials(email, password);

      if (!mounted) return;

      if (user == null) {
        _showSnackBar('Invalid email or PIN');
        return;
      }

      _showSnackBar('Welcome back, ${user.username}');
      
      // Navigate and clear the navigation stack
      if (!user.skinProfile.profileCompleted && user.skinProfile.wizardSkipCount < 3) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const SkinProfileWizard()),
          (Route<dynamic> route) => false,
        );
      } else {
        final bool showBanner = !user.skinProfile.profileCompleted && user.skinProfile.wizardSkipCount >= 3;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => Dashboard(showProfileBanner: showBanner)),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}