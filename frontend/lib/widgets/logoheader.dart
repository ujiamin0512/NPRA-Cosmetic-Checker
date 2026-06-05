import 'package:flutter/material.dart';

class LogoHeader extends StatelessWidget {
  const LogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.only(top: 2, bottom: 20),

      child: Column(
        children: [
          // Logo Image
          SizedBox(
            height: 100,
            width: 130,
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain
            ),
          ),

          // Title
          const Text(
            'NPRA Cosmetic Checker',
            style: TextStyle(
              color: Color(0xFF1D0CC2),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
           const SizedBox(height: 8),
        ],
      ),
    );
  }
}
