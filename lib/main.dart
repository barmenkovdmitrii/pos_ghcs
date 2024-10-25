import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Playground!",
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter Playground!"),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              Text("Item 1"),
              Divider(),
              Text("Item 2"),
              Divider(),
              Text("Item 3"),
            ],
          ),
        ),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Центрируем элементы в строке
            children: [
              Text("Child1"),
              SizedBox(width: 20), // Добавляем отступ между элементами
              Text("Child2"),
              SizedBox(width: 20), // Добавляем отступ между элементами
              Text("Child3"),
            ],
          ),
        ),
      ),
    );
  }
}
