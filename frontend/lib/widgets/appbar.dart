import 'package:flutter/material.dart';

class NpraAppBar extends AppBar {
  NpraAppBar({super.key, super.bottom})
      : super(
          backgroundColor: const Color(0xFF1D0CC2),
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 24,
          title: Row(
            children: [
              // App logo
              Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),

              // App title
              const Text(
                'NPRA Cosmetic Checker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
}
