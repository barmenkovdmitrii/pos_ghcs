import 'package:flutter/material.dart';
import 'package:one_clock/one_clock.dart';
import 'package:intl/intl.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: PasswordInputScreen(),
    );
  }
}

class PasswordInputScreen extends StatefulWidget {
  const PasswordInputScreen({super.key});

  @override
  _PasswordInputScreenState createState() => _PasswordInputScreenState();
}

class _PasswordInputScreenState extends State<PasswordInputScreen> {
  String _currentDateTime = '';
  late Timer _timer;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  DateTime dateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _timer = Timer.periodic(
        const Duration(seconds: 1), (timer) => _updateDateTime());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateDateTime() {
    setState(() {
      _currentDateTime = DateFormat('HH:mm:ss').format(DateTime.now());
    });
  }

  void _onNumberPressed(int number) {
    if (_controller.text.length < 6) {
      setState(() {
        _controller.text += number.toString();
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      });
    }
  }

  void _onDeletePressed() {
    setState(() {
      if (_controller.text.isNotEmpty) {
        _controller.text =
            _controller.text.substring(0, _controller.text.length - 1);
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    });
  }

  void _onSubmitPressed() {
    String enteredPassword = _controller.text;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пароль отправлен'),
        content: Text('Введённый пароль: $enteredPassword'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _controller.clear();
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    double buttonSize = (screenWidth > 300) ? 80 : screenWidth / 4;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(_focusNode);
      },
      child: Scaffold(
        body: Column(
          children: [
            // Проверяем ширину экрана
            if (screenWidth >= 650) ...[
              // Первая строка: номер сборки и часы
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                        'Номер сборки: 1.0.0'), // Замените на актуальный номер сборки
                  // ),
                  // Padding(
                    // padding: EdgeInsets.all(16.0),
                    child: DigitalClock.light(
                      format: "Hms",
                      isLive: true,
                      datetime: dateTime,
                    ),
                  )
                ],
              ),
              // Вторая строка: название
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Цифровая клавиатура',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              // Третья строка: надпись смена
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Смена',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ],
            // Четвертая строка: поле ввода пароля и цифровая клавиатура
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: buttonSize * 3 * 1.1,
                      height: 80,
                      child: TextField(
                        controller: _controller,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Введите пароль',
                          hintStyle: TextStyle(fontSize: 24),
                          border: OutlineInputBorder(),
                        ),
                        focusNode: _focusNode,
                        onChanged: (value) {
                          if (value.contains('?')) {
                            _onSubmitPressed();
                          }
                        },
                        onSubmitted: (value) {
                          _onSubmitPressed();
                        },
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 1; i <= 9; i += 3)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _buildNumberButtons(
                                    [i, i + 1, i + 2], buttonSize),
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildNumberButton(0, buttonSize),
                                _buildActionButton(Icons.backspace,
                                    _onDeletePressed, buttonSize),
                                _buildActionButton(
                                    Icons.check, _onSubmitPressed, buttonSize),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Пятая строка: копирайт
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '© 2023 Ваше имя или компания',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildNumberButtons(List<int> numbers, double buttonSize) {
    return numbers
        .map((number) => _buildNumberButton(number, buttonSize))
        .toList();
  }

  Widget _buildNumberButton(int number, double buttonSize) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () => _onNumberPressed(number),
        style: ElevatedButton.styleFrom(
          fixedSize: Size(buttonSize, buttonSize),
        ),
        child: Text(
          number.toString(),
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, VoidCallback onPressed, double buttonSize) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          fixedSize: Size(buttonSize, buttonSize),
        ),
        child: Icon(icon, size: 24),
      ),
    );
  }
}
