import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  List<List<Map<String, dynamic>>> records = [
    []
  ]; // Инициализируем только одну вкладку
  late TabController _tabController; // Контроллер для вкладок
  late TabController _buttonTabController; // Контроллер для вкладок кнопок

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: records.length, vsync: this);
    _buttonTabController = TabController(length: 15, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _buttonTabController.dispose();
    super.dispose();
  }

  void _addRecord(String title, String price) {
    setState(() {
      int currentIndex = _tabController.index;

      if (records[currentIndex].length >= 4) {
        records.add([]);
        _tabController = TabController(length: records.length, vsync: this);
      }

      _tabController.index = _tabController.length - 1;
      int newIndex = _tabController.index;
      records[newIndex].add({
        'title': title,
        'price': price,
        'count': 1,
      });
    });
  }

  void _removeRecord(int index, int recordIndex) {
    setState(() {
      records[index].removeAt(recordIndex);
      if (records[index].isEmpty) {
        records.removeAt(index);
        if (_tabController.length > 1) {
          _tabController =
              TabController(length: _tabController.length - 1, vsync: this);
          if (_tabController.index >= index) {
            _tabController.index =
                _tabController.index > 0 ? _tabController.index - 1 : 0;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            double screenHeight = MediaQuery.of(context).size.height;
            double screenWidth = MediaQuery.of(context).size.width;

            double firstRowHeight = screenHeight * 0.10;
            double secondRowHeight = screenHeight * 0.90;

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
                                    style: TextStyle(color: Colors.white))))),
                    Expanded(
                        child: Container(
                            height: firstRowHeight,
                            color: Colors.green,
                            child: Center(
                                child: Text('1/3',
                                    style: TextStyle(color: Colors.white))))),
                    Expanded(
                        child: Container(
                            height: firstRowHeight,
                            color: Colors.blue,
                            child: Center(
                                child: Text('1/3',
                                    style: TextStyle(color: Colors.white))))),
                  ],
                ),
                // Вторая строка с вкладками
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: secondRowHeight,
                        color: Colors.orange,
                        child: Column(
                          children: [
                            TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              tabs:
                                  List.generate(_tabController.length, (index) {
                                return Tab(text: 'Вкладка ${index + 1}');
                              }),
                            ),
                            Expanded(
                              child: TabBarView(
                                controller: _tabController,
                                children: List.generate(_tabController.length,
                                    (index) {
                                  return ListView.builder(
                                    itemCount: records[index].length,
                                    itemBuilder: (context, recordIndex) {
                                      return ListTile(
                                        title: Text(
                                            'Кнопка: ${records[index][recordIndex]['title']}'),
                                        subtitle: Text(
                                            'Цена: ${records[index][recordIndex]['price']}, Количество: ${records[index][recordIndex]['count']}'),
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            _removeRecord(index, recordIndex);
                                          },
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: secondRowHeight,
                        color: Colors.purple,
                        child: TabButtonPanel(
                          buttonTabController: _buttonTabController,
                          onButtonPressed: (title, price) {
                            _addRecord(title, price);
                          },
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

class TabButtonPanel extends StatelessWidget {
  final TabController buttonTabController;
  final Function(String title, String price) onButtonPressed;

  TabButtonPanel(
      {required this.buttonTabController, required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double buttonHeight = (screenHeight * 0.80) / 6; // Высота кнопки
    double buttonWidth = (screenWidth * 0.64) / 6; // Ширина кнопки

    return Column(
      children: [
        Expanded(
          child: TabBarView(
            controller: buttonTabController,
            children: List.generate(15, (tabIndex) {
              return GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, // Количество кнопок в строке
                  childAspectRatio:
                      buttonWidth / buttonHeight, // Соотношение сторон
                ),
                itemCount: 36,
                itemBuilder: (context, index) {
                  int buttonIndex =
                      index + (tabIndex * 36) + 1; // Индекс кнопки
                  return CustomButton(
                    title: 'Кнопка $buttonIndex',
                    price: '${buttonIndex * 3}.00',
                    weight: '${buttonIndex * 0.5} кг', // Добавляем вес
                    onPressed: () {
                      // Добавляем запись при нажатии на кнопку
                      onButtonPressed(
                          'Кнопка $buttonIndex', '${buttonIndex * 3}.00');
                    },
                    buttonHeight: buttonHeight, // Передаем высоту кнопки
                    buttonWidth: buttonWidth, // Передаем ширину кнопки
                  );
                },
              );
            }),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (buttonTabController.index > 0) {
                  buttonTabController.animateTo(buttonTabController.index - 1);
                }
              },
            ),
            Expanded(
              child: TabBar(
                controller: buttonTabController,
                isScrollable: true, // Позволяет прокручивать вкладки
                tabs: List.generate(15, (index) {
                  return Tab(
                    child: Container(
                      width: screenWidth *
                          0.66 /
                          4, // Устанавливаем ширину контейнера
                      child: Text(
                        'Кнопки с длинной надписью что бы было ${index + 1}',
                        style: TextStyle(
                            color: Colors
                                .white), // Устанавливаем белый цвет текста
                        maxLines: 2, // Ограничиваем количество строк до 2
                        overflow: TextOverflow
                            .ellipsis, // Обрезаем текст, если он длиннее
                      ),
                    ),
                  );
                }),
                indicatorColor: Colors.white, // Устанавливаем цвет индикатора
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                if (buttonTabController.index <
                    buttonTabController.length - 1) {
                  buttonTabController.animateTo(buttonTabController.index + 1);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String title;
  final String price;
  final String weight; // Добавляем параметр для веса
  final VoidCallback onPressed; // Добавляем колбек для нажатия
  final double buttonHeight; // Высота кнопки
  final double buttonWidth; // Ширина кнопки

  CustomButton({
    required this.title,
    required this.price,
    required this.weight, // Инициализируем параметр веса
    required this.onPressed, // Инициализируем колбек
    required this.buttonHeight, // Инициализируем высоту кнопки
    required this.buttonWidth, // Инициализируем ширину кнопки
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed, // Вызываем колбек при нажатии
      child: Container(
        height: buttonHeight, // Устанавливаем высоту кнопки
        width: buttonWidth, // Устанавливаем ширину кнопки
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
                width: buttonWidth - 20, // Уменьшаем ширину для отступов
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: buttonHeight * 0.15, // 15% от высоты кнопки
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
                weight, // Отображаем вес
                style: TextStyle(
                  color: Colors.white,
                  fontSize: buttonHeight * 0.1, // 10% от высоты кнопки
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
                  fontSize: buttonHeight * 0.1, // 10% от высоты кнопки
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
