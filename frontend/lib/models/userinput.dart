import 'package:flutter/material.dart';

/// A lightweight specification model used to configure reusable input widgets.
/// This is NOT a UI widget — it only stores metadata for an input field.
class InputFieldSpec {
  const InputFieldSpec({
    required this.hintText,
    this.keyboardType,
    this.isPassword = false,
  });

  final String hintText;
  final TextInputType? keyboardType;
  final bool isPassword;

  InputFieldSpec copyWith({
    String? hintText,
    TextInputType? keyboardType,
    bool? isPassword,
  }) {
    return InputFieldSpec(
      hintText: hintText ?? this.hintText,
      keyboardType: keyboardType ?? this.keyboardType,
      isPassword: isPassword ?? this.isPassword,
    );
  }

  // Predefined reusable field specifications
  static const InputFieldSpec username = InputFieldSpec(
    hintText: 'Username',
    keyboardType: TextInputType.name,
  );

  static const InputFieldSpec email = InputFieldSpec(
    hintText: 'Email',
    keyboardType: TextInputType.emailAddress,
  );

  static const InputFieldSpec password = InputFieldSpec(
    hintText: '6-digit PIN',
    keyboardType: TextInputType.number,
    isPassword: true,
  );

  static const InputFieldSpec confirmPassword = InputFieldSpec(
    hintText: 'Confirm 6-digit PIN',
    keyboardType: TextInputType.number,
    isPassword: true,
  );

  static const InputFieldSpec phoneNumber = InputFieldSpec(
    hintText: 'Phone Number',
    keyboardType: TextInputType.phone,
  );
}
