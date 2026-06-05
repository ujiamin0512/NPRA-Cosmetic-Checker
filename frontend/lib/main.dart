import 'package:flutter/material.dart';

import 'package:assignment_2/views/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: LoginPage()
  ));
}