// main.dart
import 'package:flutter/material.dart';
import 'pos_authorization.dart'; // pos_authorization.dart

void main() {
  runApp(const POS());
}

class POS extends StatelessWidget {
  const POS({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS GHCS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
          const PosAuthorization(), // Используем PosAuthorization из pos_authorization.dart
    );
  }
}
