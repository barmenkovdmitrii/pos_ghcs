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
    final screenHeight = MediaQuery.of(context).size.height;
    final firstRowHeight = screenHeight * 0.15;
    final thirdRowHeight = screenHeight * 0.15;
    final gridHeight = screenHeight * 0.70;

    return Column(
      children: [
        // Первая строка (15% высоты экрана)
        Container(
          height: firstRowHeight,
          child: Row(
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
                    // Кнопки в первой строке
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Действие для первой кнопки
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text('Кнопка 1'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Действие для второй кнопки
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text('Кнопка 2'),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Действие для третьей кнопки
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: Text('Кнопка 3'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Вторая строка (70% высоты экрана)
        Container(
          height: gridHeight,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.grey[300],
                  child: Center(
                    child: Text('Первый столбец'),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 36,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          onPressed: () {
                            // Действие для кнопки
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: Text('Кнопка ${index + 1}'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        // Третья строка (15% высоты экрана)
        Container(
          height: thirdRowHeight,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Действие для первой кнопки в третьем столбце
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text('Кнопка A'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Действие для второй кнопки в третьем столбце
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      child: Text('Кнопка B'),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  color: Colors.grey[200], // Цвет фона для второго столбца
                  child: Center(
                    child: Text('Второй столбец'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
