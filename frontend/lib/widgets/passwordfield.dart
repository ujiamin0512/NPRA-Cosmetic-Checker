import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/userinput.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.spec,
  });

  final TextEditingController controller;
  final InputFieldSpec spec;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  void _toggleVisibility() {
    setState(() {
      _obscure = !_obscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: widget.spec.keyboardType,
      inputFormatters: widget.spec.keyboardType == TextInputType.number
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ]
          : null,
      decoration: InputDecoration(
        hintText: widget.spec.hintText,
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
        suffixIcon: IconButton(
          onPressed: _toggleVisibility,
          icon: Icon(
            _obscure ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF8A8DA4),
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
