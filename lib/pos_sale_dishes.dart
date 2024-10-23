import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  List<List<Map<String, dynamic>>> records = [[]];
  late TabController _tabController;
  late TabController _buttonTabController;
  Map<int, int> buttonClickCounts =
      {}; // Хранит количество нажатий для каждой кнопки

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

  void _addRecord(String title, String price, int buttonIndex) {
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
        'buttonIndex': buttonIndex, // Сохраняем индекс кнопки
      });
    });
  }

  void _removeRecord(int index, int recordIndex) {
    setState(() {
      // Получаем индекс кнопки, связанной с записью
      int buttonIndex = records[index][recordIndex]['buttonIndex'];

      // Уменьшаем количество нажатий на кнопке
      buttonClickCounts[buttonIndex] =
          (buttonClickCounts[buttonIndex] ?? 1) - 1;

      // Удаляем запись
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

  void _incrementButtonClick(int buttonIndex) {
    setState(() {
      buttonClickCounts[buttonIndex] =
          (buttonClickCounts[buttonIndex] ?? 0) + 1;
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
                //вторая строка
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
                          onButtonPressed: (title, price, buttonIndex) {
                            _addRecord(title, price, buttonIndex);
                          },
                          onButtonClick: (buttonIndex) {
                            _incrementButtonClick(buttonIndex);
                          },
                          buttonClickCounts: buttonClickCounts,
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
  final Function(String title, String price, int buttonIndex) onButtonPressed;
  final Function(int buttonIndex) onButtonClick;
  final Map<int, int> buttonClickCounts;

  TabButtonPanel({
    required this.buttonTabController,
    required this.onButtonPressed,
    required this.onButtonClick,
    required this.buttonClickCounts,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double buttonHeight = (screenHeight * 0.80) / 6;
    double buttonWidth = (screenWidth * 0.64) / 6;

    return Column(
      children: [
        Expanded(
          child: TabBarView(
            controller: buttonTabController,
            children: List.generate(15, (tabIndex) {
              return GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  childAspectRatio: buttonWidth / buttonHeight,
                ),
                itemCount: 36,
                itemBuilder: (context, index) {
                  int buttonIndex = index + (tabIndex * 36) + 1;
                  return CustomButton(
                    title: 'Кнопка $buttonIndex',
                    price: '${buttonIndex * 3}.00',
                    weight: '${buttonIndex * 0.5} кг',
                    onPressed: () {
                      onButtonPressed(
                          'Кнопка $buttonIndex',
                          '${buttonIndex * 3}.00',
                          buttonIndex); // Передаем индекс кнопки
                      onButtonClick(
                          buttonIndex); // Увеличиваем количество нажатий
                    },
                    buttonHeight: buttonHeight,
                    buttonWidth: buttonWidth,
                    clickCount: buttonClickCounts[buttonIndex] ??
                        0, // Передаем количество нажатий
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
                  buttonTabController.animateTo(buttonTabController.index - 4);
                }
              },
            ),
            Expanded(
              child: TabBar(
                controller: buttonTabController,
                isScrollable: true,
                tabs: List.generate(15, (index) {
                  return Tab(
                    child: Container(
                      width: screenWidth * 0.66 / 4,
                      child: Text(
                        'Кнопки с длинной надписью что бы было ${index + 1}',
                        style: TextStyle(color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }),
                indicatorColor: Colors.white,
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () {
                if (buttonTabController.index <
                    buttonTabController.length - 1) {
                  buttonTabController.animateTo(buttonTabController.index + 4);
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
  final String weight;
  final VoidCallback onPressed;
  final double buttonHeight;
  final double buttonWidth;
  final int clickCount; // Добавляем параметр для количества нажатий

  CustomButton({
    required this.title,
    required this.price,
    required this.weight,
    required this.onPressed,
    required this.buttonHeight,
    required this.buttonWidth,
    required this.clickCount, // Инициализируем параметр количества нажатий
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed, // Вызываем метод при нажатии
      child: Container(
        height: buttonHeight,
        width: buttonWidth,
        margin: EdgeInsets.all(4.0),
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
                width: buttonWidth - 20,
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: buttonHeight * 0.15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 10,
              child: Text(
                weight,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: buttonHeight * 0.1,
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
                  fontSize: buttonHeight * 0.1,
                ),
              ),
            ),
            // Отображаем количество нажатий только если оно больше 0
            if (clickCount > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$clickCount', // Отображаем количество нажатий
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: buttonHeight * 0.1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
