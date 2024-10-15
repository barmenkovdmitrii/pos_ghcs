import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _timer = Timer.periodic(
        const Duration(seconds: 1), (timer) => _updateDateTime());

    // Устанавливаем фокус на поле ввода пароля после построения виджета
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
      _currentDateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    });
  }

  void _onNumberPressed(int number) {
    if (_controller.text.length < 6) {
      setState(() {
        _controller.text += number.toString(); // Обновляем текст контроллера
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length), // Устанавливаем курсор в конец
        );
      });
    }
  }

  void _onDeletePressed() {
    setState(() {
      if (_controller.text.isNotEmpty) {
        _controller.text = _controller.text.substring(0, _controller.text.length - 1); // Удаляем последний символ
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length), // Устанавливаем курсор в конец
        );
      }
    });
  }

  void _onSubmitPressed() {
    String enteredPassword = _controller.text; // Получаем текст из контроллера
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пароль отправлен'),
        content: Text('Введённый пароль: $enteredPassword'), // Используем введённый пароль
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _controller.clear(); // Очищаем контроллер
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
        // Устанавливаем фокус на поле ввода при нажатии на любую область экрана
        FocusScope.of(context).requestFocus(_focusNode);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Цифровая клавиатура'),
          actions: [
            if (screenWidth >= 400) // если размер экрана больше 400 прекратить масштабирование
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Text(
                    _currentDateTime,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: buttonSize * 3 * 1.1, // 80% от ширины трех кнопок
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
                      // Проверяем, содержит ли текст символ '?'
                      if (value.contains('?')) {
                        _onSubmitPressed(); // Исправлено: вызов метода
                      }
                    },
                    onSubmitted: (value) {
                      _onSubmitPressed();
                    },
                    style: const TextStyle(fontSize: 24),
                  ),
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
                          children:
                              _buildNumberButtons([i, i + 1, i + 2], buttonSize),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildNumberButton(0, buttonSize),
                          _buildActionButton(
                              'Удалить', _onDeletePressed, buttonSize),
                          _buildActionButton(
                              'Ввод', _onSubmitPressed, buttonSize),
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
      String label, VoidCallback onPressed, double buttonSize) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          fixedSize: Size(buttonSize, buttonSize),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}



/* Форма в виджетами для ввода пароля на кассе*/