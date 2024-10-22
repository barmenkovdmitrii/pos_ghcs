import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Playground",
      home: Scaffold(
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width:
                    100, // Устанавливаем ширину контейнера для обрезки текста
                child: Text(
                  "Child1",
                  overflow: TextOverflow.ellipsis, // Обрезка текста
                  textAlign: TextAlign.center, // Выравнивание текста по центру
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Transform(transform.scale: 2.0,
                    child: Text("Child2"),
                  ),
                ),
              ),
              Text("Child3"),
            ],
          ),
        ),
      ),
    );
  }
}
