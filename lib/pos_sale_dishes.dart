import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: MyForm(),
      ),
    );
  }
}

class MyForm extends StatefulWidget {
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  String _currentTime = '';
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    setState(() {
      _currentTime = TimeOfDay.now().format(context);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Название точки'),
                  Text('Имя кассира'),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  _currentTime,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Действие для первой кнопки
                    },
                    child: Text('Кнопка 1'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Действие для второй кнопки
                    },
                    child: Text('Кнопка 2'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Действие для третьей кнопки
                    },
                    child: Text('Кнопка 3'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}