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
                      child: Container(
                        height: firstRowHeight,
                        color: Colors.white,
                        child: DigitalClock.light(
                          format: "Hms",
                          isLive: true,
                          datetime: dateTime,
                        ),
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
                              //color: Colors.lightBlue,
                              child: ButtonFooterRow(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: secondRowHeight,
                        color: Colors.white, // фон под кнопками 6х6
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

  void _onArrowForwardPressed() {
    int newIndex = buttonTabController.index + 4;
    if (newIndex >= buttonTabController.length) {
      newIndex = buttonTabController.length -
          1; // Перемещение не должно выходить за пределы
    }
    buttonTabController.animateTo(newIndex);
  }

  void _onArrowBackPressed() {
    int newIndex = buttonTabController.index - 4;
    if (newIndex < 0) {
      newIndex = 0; // Перемещение не должно выходить за пределы
    }
    buttonTabController.animateTo(newIndex);
  }

  void _onFirstTabPressed() {
    buttonTabController.animateTo(0);
  }

  void _onLastTabPressed() {
    buttonTabController.animateTo(buttonTabController.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double buttonHeight = (screenHeight * 0.77) / 6;
    double buttonWidth = (screenWidth * 0.64) / 6;
    double tabBarHeight = screenHeight * 0.05; // Высота одного TabBar
    double buttonContainerHeight =
        screenHeight * 0.05; // Высота кнопок 10% от высоты экрана

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
        // Row для кнопок и TabBar
        Container(
          height: buttonContainerHeight, // Высота кнопок 10% от высоты экрана
          color: Colors.green.shade50, // Цвет фона для кнопок
          child: Row(
            children: [
              // Первая колонка с кнопкой "Arrow Back"
              Container(
                width: 48, // Фиксированная ширина для кнопки "Arrow Back"
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                  onPressed: _onArrowBackPressed,
                ),
              ),
              // Вторая колонка с TabBar
              Expanded(
                child: TabBar(
                  controller: buttonTabController,
                  isScrollable: true,
                  tabs: List.generate(15, (index) {
                    if (index % 2 == 0) {
                      // Четные индексы
                      return Tab(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.66 / 4,
                          child: Text(
                            'Четная кнопка ${index + 1}',
                            style: const TextStyle(color: Colors.black),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    } else {
                      return Tab(
                          child: SizedBox
                              .shrink()); // Пустая вкладка для нечетных индексов
                    }
                  }),
                  indicatorColor: Colors.red,
                ),
              ),
              // Третья колонка с кнопкой "Arrow Forward"
              Container(
                width: 48, // Фиксированная ширина для кнопки "Arrow Forward"
                child: IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: Colors.black),
                  onPressed: _onArrowForwardPressed,
                ),
              ),
            ],
          ),
        ),
        // Нижняя TabBar для нечетных индексов
        Container(
          height: tabBarHeight, // Высота одного TabBar
          color: Colors.green.shade50, // Цвет фона для TabBar
          child: Row(
            children: [
              // Кнопка "Первая вкладка"
              Container(
                width: 48, // Фиксированная ширина для кнопки "Первая вкладка"
                child: IconButton(
                  icon: Icon(Icons.first_page, color: Colors.black),
                  onPressed: _onFirstTabPressed,
                ),
              ),
              // Вторая колонка с TabBar
              Expanded(
                child: TabBar(
                  controller: buttonTabController,
                  isScrollable: true,
                  tabs: List.generate(15, (index) {
                    if (index % 2 != 0) {
                      // Нечетные индексы
                      return Tab(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.66 / 4,
                          child: Text(
                            'Нечетная кнопка ${index + 1}',
                            style: const TextStyle(color: Colors.black),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    } else {
                      return Tab(
                          child: SizedBox
                              .shrink()); // Пустая вкладка для четных индексов
                    }
                  }),
                  indicatorColor: Colors.red,
                ),
              ),
              // Кнопка "Последняя вкладка"
              Container(
                width:
                    48, // Фиксированная ширина для кнопки "Последняя вкладка"
                child: IconButton(
                  icon: Icon(Icons.last_page, color: Colors.black),
                  onPressed: _onLastTabPressed,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ButtonFirstRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceEvenly, // Равные интервалы между кнопками
        children: [
          _buildButton(Icons.apps, () {}, context), // Пустая функция
          SizedBox(width: 1),
          _buildButton(Icons.dehaze, () {}, context), // Пустая функция
          SizedBox(width: 1),
          _buildButton(Icons.lock, () {}, context), // Пустая функция
        ],
      ),
    );
  }

  Widget _buildButton(
      IconData icon, VoidCallback onPressed, BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double buttonHeight = screenHeight * 0.09; // 9% от высоты экрана
    double buttonWidth = screenWidth / 10;

    return Container(
      width: buttonWidth, // Ширина кнопки
      height: buttonHeight, // Высота кнопки
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Убираем закругление
          ),
        ),
        onPressed: onPressed, // Устанавливаем действие при нажатии
        child: Icon(
          icon,
          size: buttonHeight * 0.5,
          color: Colors.grey,
        ), // Устанавливаем иконку кнопки
      ),
    );
  }
}

class ButtonFooterRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 1, // Первая кнопка занимает 1/3
            child: _buildButton(
                Icons.thumbs_up_down, () {}, context), // Пустая функция
          ),
          SizedBox(width: 8), // Расстояние между кнопками
          Expanded(
            flex: 2, // Вторая кнопка занимает 2/3
            child: _buildPaymentButton(() {}, context), // Пустая функция
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      IconData icon, VoidCallback onPressed, BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double buttonHeight = screenHeight * 0.09; // 9% от высоты экрана

    return Container(
      height: buttonHeight, // Высота кнопки
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Убираем закругление
          ),
        ),
        onPressed: onPressed, // Устанавливаем действие при нажатии
        child: Icon(
          icon,
          size: buttonHeight * 0.5, // Устанавливаем размер иконки
          color: Colors.grey,
        ), // Устанавливаем иконку кнопки
      ),
    );
  }

  Widget _buildPaymentButton(VoidCallback onPressed, BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double buttonHeight = screenHeight * 0.09; // 9% от высоты экрана

    return Container(
      height: buttonHeight, // Высота кнопки
      child: Material(
        color: Colors.red.shade900, // Устанавливаем цвет кнопки в красный
        borderRadius: BorderRadius.zero, // Убираем закругление
        child: InkWell(
          onTap: onPressed, // Устанавливаем действие при нажатии
          borderRadius: BorderRadius.zero, // Убираем закругление
          splashColor: Colors.white.withOpacity(0.5), // Цвет эффекта нажатия
          highlightColor: Colors.white.withOpacity(0.3), // Цвет при нажатии
          child: Container(
            height: buttonHeight, // Высота кнопки
            alignment: Alignment.center, // Центрируем содержимое
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Центрируем содержимое
              children: [
                Icon(
                  Icons.payments, // Иконка слева
                  size: buttonHeight * 0.5, // Устанавливаем размер иконки
                  color: Colors.white, // Устанавливаем цвет иконки в белый
                ),
                SizedBox(width: 8), // Расстояние между иконкой и текстом
                Text(
                  'ОПЛАТА', // Текст кнопки
                  style: TextStyle(
                    fontSize: buttonHeight * 0.3, // Устанавливаем размер текста
                    color: Colors.white, // Устанавливаем цвет текста в белый
                  ),
                ),
              ],
            ),
          ),
        ),
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
