import 'package:flutter/material.dart';
import 'package:one_clock/one_clock.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Clock Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Digital Clock with INTL Format'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                "Digital Clock Example with Custom INTL Format",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DigitalClock(
                    format: "H",
                    showSeconds: true,
                    datetime: dateTime,
                    textScaleFactor: 1.3,
                    isLive: true,
                  ),
                  const SizedBox(width: 10),
                  DigitalClock.dark(
                    format: "Hm",
                    datetime: dateTime,
                  ),
                  const SizedBox(width: 10),
                  DigitalClock.light(
                    format: "Hms",
                    isLive: true,
                    datetime: dateTime,
                  ),
                  const SizedBox(width: 10),
                  DigitalClock(
                    format: 'yMMMEd',
                    datetime: dateTime,
                    textScaleFactor: 1,
                    showSeconds: false,
                    isLive: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
