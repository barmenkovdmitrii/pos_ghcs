import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> records = []; // Список для хранения записей

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Получаем высоту и ширину экрана
            double screenHeight = MediaQuery.of(context).size.height;
            double screenWidth = MediaQuery.of(context).size.width;

            // Высота строк
            double firstRowHeight = screenHeight * 0.10;
            double secondRowHeight = screenHeight * 0.75;
            double thirdRowHeight = screenHeight * 0.15;

            // Высота кнопок (70% высоты экрана, делённая на 6)
            double buttonHeight = (screenHeight * 0.71) / 6;

            // Ширина кнопов (65% от ширины экрана, делённая на 6)
            double buttonWidth = screenWidth * 0.63 / 6;

            return Column(
              children: [
                // Первая строка
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: firstRowHeight,
                        color: Colors.red,
                        child: Center(
                            child: Text('1/3',
                                style: TextStyle(color: Colors.white))),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: firstRowHeight,
                        color: Colors.green,
                        child: Center(
                            child: Text('1/3',
                                style: TextStyle(color: Colors.white))),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: firstRowHeight,
                        color: Colors.blue,
                        child: Center(
                            child: Text('1/3',
                                style: TextStyle(color: Colors.white))),
                      ),
                    ),
                  ],
                ),
                // Вторая строка
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: secondRowHeight,
                        color: Colors.orange,
                        child: ListView.builder(
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(records[index]),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Введите текст...',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      // Удаляем запись из списка при нажатии на кнопку
                                      setState(() {
                                        records.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: secondRowHeight,
                        color: Colors.purple,
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6, // Количество кнопок в строке
                            childAspectRatio: buttonWidth /
                                buttonHeight, // Соотношение сторон
                          ),
                          itemCount: 36,
                          itemBuilder: (context, index) {
                            return CustomButton(
                              title: 'Кнопка ${index + 1}',
                              number: '${index + 1}',
                              price: '\${(index + 1) * 10}.00',
                              onPressed: () {
                                // Добавляем запись в список при нажатии на кнопку
                                setState(() {
                                  records.add('Кнопка ${index + 1}');
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                // Третья строка
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: thirdRowHeight,
                        color: Colors.yellow,
                        child: Center(
                            child: Text('1/3',
                                style: TextStyle(color: Colors.white))),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: thirdRowHeight,
                        color: Colors.cyan,
                        child: Center(
                          child: Text(
                            'Высота кнопки: ${buttonHeight.toStringAsFixed(2)}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String title;
  final String number;
  final String price;
  final VoidCallback onPressed; // Добавляем колбек для нажатия

  CustomButton({
    required this.title,
    required this.number,
    required this.price,
    required this.onPressed, // Инициализируем колбек
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Получаем размеры кнопки
        double buttonHeight = constraints.maxHeight; // Высота кнопки

        // Вычисляем размер шрифта в зависимости от высоты кнопки
        double titleFontSize = buttonHeight * 0.15; // 15% от высоты кнопки
        double numberFontSize = buttonHeight * 0.1; // 10% от высоты кнопки
        double priceFontSize = buttonHeight * 0.1; // 10% от высоты кнопки

        return GestureDetector(
          onTap: onPressed, // Вызываем колбек при нажатии
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
                  child: Container(
                    width: constraints.maxWidth -
                        20, // Уменьшаем ширину для отступов
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2, // Максимальное количество строк
                      overflow: TextOverflow.visible, // Перенос текста
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
