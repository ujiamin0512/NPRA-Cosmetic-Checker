import 'package:flutter/material.dart';

import '../models/userinput.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.controller,
    required this.spec,
  });

  final TextEditingController controller;
  final InputFieldSpec spec;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: spec.keyboardType,
      decoration: InputDecoration(
        hintText: spec.hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF8A8DA4),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF1D0CC2),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF1D0CC2),
            width: 2.5,
          ),
        ),
      ),
      style: const TextStyle(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
