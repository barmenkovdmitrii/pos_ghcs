import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:one_clock/one_clock.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  List<List<Map<String, dynamic>>> records = [[]];
  late TabController _tabController;
  late TabController _buttonTabController;
  Map<int, int> buttonClickCounts = {};
  DateTime dateTime = DateTime.now();

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

      bool exists = false;
      for (var record in records[newIndex]) {
        if (record['title'] == title && record['price'] == price) {
          record['count'] += 1;
          exists = true;
          break;
        }
      }

      if (!exists) {
        records[newIndex].add({
          'title': title,
          'price': price,
          'count': 1,
          'buttonIndex': buttonIndex,
        });
      }
    });
  }

  void _removeRecord(int index, int recordIndex) {
    setState(() {
      int buttonIndex = records[index][recordIndex]['buttonIndex'];
      buttonClickCounts[buttonIndex] =
          (buttonClickCounts[buttonIndex] ?? 1) - 1;
      records[index][recordIndex]['count'] -= 1;

      if (records[index][recordIndex]['count'] <= 0) {
        records[index].removeAt(recordIndex);
      }

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

  // Метод для вычисления общей суммы
  double _calculateTotal() {
    double total = 0.0;
    for (var tabRecords in records) {
      for (var record in tabRecords) {
        double price = double.tryParse(record['price']) ?? 0.0;
        int count = record['count'];
        total += price * count;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            double screenHeight = MediaQuery.of(context).size.height;
            double screenWidth = MediaQuery.of(context).size.width;

            double firstRowHeight =
                screenHeight * 0.10; // 10% для последней строки
            double secondRowHeight =
                screenHeight * 0.90; // 90% для основной части

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: firstRowHeight,
                        color: Colors.red,
                        child: const Center(
                          child: Text(
                            '1/3',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    // Часы в середине
                    Expanded(
                      child: DigitalClock.light(
                        format: "Hms",
                        isLive: true,
                        datetime: dateTime,
                      ),
                    ),
                    Expanded(
                      child: ButtonFirstRow(), // Три кнопки
                    ),
                  ],
                ),
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
                              child: CustomTabBarView(
                                tabController: _tabController,
                                records: records,
                                onRemoveRecord: _removeRecord,
                              ),
                            ),
                            // Добавляем строку для отображения общей суммы
                            Container(
                              height:
                                  firstRowHeight / 2, // 10% от высоты экрана
                              color: Colors.yellow,
                              child: Center(
                                child: Text(
                                  'СУММА:     ${NumberFormat('#,##0.00', 'ru_RU').format(_calculateTotal())}',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenHeight * 0.04),
                                ),
                              ),
                            ),
                            // Добавляем новую строку
                            Container(
                              height: firstRowHeight, // 10% от высоты экрана
                              color: Colors.lightBlue,
                              child: const Center(
                                child: Text(
                                  'Дополнительная строка',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                ),
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

class CustomTabBarView extends StatelessWidget {
  final TabController tabController;
  final List<List<Map<String, dynamic>>> records;
  final Function(int index, int recordIndex) onRemoveRecord;

  const CustomTabBarView({
    super.key,
    required this.tabController,
    required this.records,
    required this.onRemoveRecord,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: List.generate(tabController.length, (index) {
        return CustomListView(
          records: records[index],
          onRemoveRecord: (recordIndex) {
            onRemoveRecord(index, recordIndex);
          },
        );
      }),
    );
  }
}

class CustomListView extends StatelessWidget {
  final List<Map<String, dynamic>> records;
  final Function(int recordIndex) onRemoveRecord;

  const CustomListView({
    super.key,
    required this.records,
    required this.onRemoveRecord,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, recordIndex) {
        // Преобразуем цену в double
        double price = double.tryParse(records[recordIndex]['price']) ?? 0.0;
        int count = records[recordIndex]['count'];
        double total = price * count; // Вычисляем итог

        return ListTile(
          title: Text('Кнопка: ${records[recordIndex]['title']}'),
          subtitle: Text(
              'Цена: ${records[recordIndex]['price']}, Количество: $count, Итог: ${total.toStringAsFixed(2)}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              onRemoveRecord(recordIndex);
            },
          ),
        );
      },
    );
  }
}

class TabButtonPanel extends StatelessWidget {
  final TabController buttonTabController;
  final Function(String title, String price, int buttonIndex) onButtonPressed;
  final Function(int buttonIndex) onButtonClick;
  final Map<int, int> buttonClickCounts;

  const TabButtonPanel({
    super.key,
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
                physics: const NeverScrollableScrollPhysics(),
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
                      onButtonPressed('Кнопка $buttonIndex',
                          '${buttonIndex * 3}.00', buttonIndex);
                      onButtonClick(buttonIndex);
                    },
                    buttonHeight: buttonHeight,
                    buttonWidth: buttonWidth,
                    clickCount: buttonClickCounts[buttonIndex] ?? 0,
                  );
                },
              );
            }),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (buttonTabController.index > 0) {
                  buttonTabController.animateTo(buttonTabController.index - 1);
                }
              },
            ),
            Expanded(
              child: TabBar(
                controller: buttonTabController,
                isScrollable: true,
                tabs: List.generate(15, (index) {
                  return Tab(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.66 / 4,
                      child: Text(
                        'Кнопки с длинной надписью что бы было ${index + 1}',
                        style: const TextStyle(color: Colors.white),
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
              icon: const Icon(Icons.arrow_forward),
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

class ButtonFirstRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly, // Равные интервалы между кнопками
        children: [
          _buildButton('Кнопка 1', () {}, context), // Пустая функция
          _buildButton('Кнопка 2', () {}, context), // Пустая функция
          _buildButton('Кнопка 3', () {}, context), // Пустая функция
        ],
      ),
    );
  }

  Widget _buildButton(
      String title, VoidCallback onPressed, BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonHeight = screenHeight * 0.09; // 9% от высоты экрана

    return Container(
      width: 80, // Ширина кнопки
      height: buttonHeight, // Высота кнопки
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Убираем закругление
          ),
        ),
        onPressed: onPressed, // Устанавливаем действие при нажатии
        child: Text(title), // Устанавливаем текст кнопки
      ),
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
  final int clickCount;

  const CustomButton({
    super.key,
    required this.title,
    required this.price,
    required this.weight,
    required this.onPressed,
    required this.buttonHeight,
    required this.buttonWidth,
    required this.clickCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: buttonHeight,
        width: buttonWidth,
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 10,
              child: SizedBox(
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
            if (clickCount > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$clickCount',
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
