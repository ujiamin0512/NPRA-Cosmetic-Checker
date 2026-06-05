import 'package:flutter/material.dart';

import '../models/profile.dart';
import 'aboutapp_page.dart';
import 'edit_page.dart';
import 'password_page.dart';
import 'skin_profile_page.dart';

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({super.key, required this.option});

  final ProfileOption option;

  static final List<Widget Function()> _profilePages = <Widget Function()>[
    () => const EditProfilePage(),
    () => const PasswordPage(),
    () => const AboutAppPage(),
    () => const SkinProfilePage(),
  ];

  bool get _hasPage =>
      option.pageIndex != null &&
      option.pageIndex! >= 0 &&
      option.pageIndex! < _profilePages.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D0CC2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          option.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: _hasPage
              ? _profilePages[option.pageIndex!]()
              : _FallbackDetailsBody(description: option.description),
        ),
      ),
    );
  }
}

class _FallbackDetailsBody extends StatelessWidget {
  const _FallbackDetailsBody({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Text(
        description,
        style: const TextStyle(
          color: Color(0xFF333752),
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }
}
