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
        body: Column(
          children: [
            // Первая строка (10% высоты экрана)
            Container(
              height: MediaQuery.of(context).size.height * 0.1,
              child: Row(
                children: [
                  Expanded(child: Container()), // Первая колонка
                  Expanded(
                    child: Center(
                      child: TimeDisplay(), // Вторая колонка с часами
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {}, child: Text('Кнопка 1')),
                        ElevatedButton(
                            onPressed: () {}, child: Text('Кнопка 2')),
                        ElevatedButton(
                            onPressed: () {}, child: Text('Кнопка 3')),
                      ],
                    ),
                  ), // Третья колонка с кнопками
                ],
              ),
            ),
            // Вторая строка (75% высоты экрана)
            Container(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(), // Первый столбец (1/3)
                  ),
                  Expanded(
                    flex: 2,
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 6, // Количество колонок
                        childAspectRatio: 1, // Соотношение сторон
                      ),
                      itemCount: 36, // Общее количество кнопок
                      itemBuilder: (context, index) {
                        return CustomButton(
                          title: 'Кнопка ${index + 1}',
                          number: '${index + 1}',
                          price: '\${(index + 1) * 10}.00', // Исправлено
                        );
                      },
                    ),
                  ), // Второй столбец (2/3) с полем 6x6
                ],
              ),
            ),
            // Третья строка (15% высоты экрана)
            Container(
              height: MediaQuery.of(context).size.height * 0.15,
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () {}, child: Text('Кнопка A')),
                        ElevatedButton(
                            onPressed: () {}, child: Text('Кнопка B')),
                      ],
                    ),
                  ), // Первый столбец с двумя кнопками
                  Expanded(
                    flex: 2,
                    child: Container(), // Второй столбец (2/3)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeDisplay extends StatefulWidget {
  @override
  _TimeDisplayState createState() => _TimeDisplayState();
}

class _TimeDisplayState extends State<TimeDisplay> {
  String _timeString = "";

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    setState(() {
      final now = DateTime.now();
      _timeString =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _timeString,
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String title;
  final String number;
  final String price;

  CustomButton(
      {required this.title, required this.number, required this.price});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonHeight = constraints.maxHeight;

        double titleFontSize = buttonHeight * 0.15;
        double numberFontSize = buttonHeight * 0.1;
        double priceFontSize = buttonHeight * 0.1;

        return GestureDetector(
          onTap: () {
            print('$title нажата');
          },
          child: Container(
            margin: EdgeInsets.all(4.0), // Отступы между кнопками
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  left: 10,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Text(
                    number,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: numberFontSize,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Text(
                    price,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: priceFontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
