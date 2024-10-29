// main.dart
import 'package:flutter/material.dart';
import 'pos_authorization.dart'; // pos_authorization.dart

void main() {
  runApp(POS());
}

class POS extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS GHCS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:
          PosAuthorization(), // Используем PosAuthorization из pos_authorization.dart
    );
  }
}
