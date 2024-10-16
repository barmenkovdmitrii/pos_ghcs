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
  ]; // Список для хранения записей для каждой вкладки
  late TabController _tabController; // Контроллер для вкладок

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 1, vsync: this); // Инициализация контроллера с одной вкладкой
  }

  @override
  void dispose() {
    _tabController.dispose(); // Освобождение ресурсов контроллера
    super.dispose();
  }

  void _addRecord(String title, String price) {
    setState(() {
      int currentIndex =
          _tabController.index; // Получаем индекс текущей вкладки

      // Проверяем, существует ли уже запись для нажатой кнопки
      int existingIndex = records[currentIndex]
          .indexWhere((record) => record['title'] == title);
      if (existingIndex != -1) {
        // Если запись существует, увеличиваем количество нажатий
        records[currentIndex][existingIndex]['count']++;
      } else {
        // Проверяем, нужно ли добавить новую вкладку
        if (records[currentIndex].length >= 4) {
          // Если в текущей вкладке 4 записи, создаем новую вкладку
          records.add([]); // Добавляем новый список для новой вкладки
          _tabController =
              TabController(length: _tabController.length + 1, vsync: this);
          _tabController.index =
              _tabController.length - 1; // Переключаем фокус на новую вкладку
          currentIndex =
              _tabController.index; // Обновляем текущий индекс на новую вкладку
        }

        // Добавляем новую запись в текущую или новую вкладку
        records[currentIndex].add({
          'title': title,
          'price': price,
          'count': 1, // Начальное количество нажатий
        });
      }
    });
  }

  void _removeRecord(int index, int recordIndex) {
    setState(() {
      records[index].removeAt(recordIndex);

      // Проверяем, если вкладка пустая, удаляем её
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
            double secondRowHeight = screenHeight * 0.75;
            double thirdRowHeight = screenHeight * 0.15;

            double buttonHeight = (screenHeight * 0.71) / 6;
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
                                            _removeRecord(index,
                                                recordIndex); // Используем новый метод для удаления
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
                              price: '${(index + 1) * 3}.00',
                              weight:
                                  '${(index + 1) * 0.5} кг', // Добавляем вес
                              onPressed: () {
                                // Добавляем запись при нажатии на кнопку
                                _addRecord('Кнопка ${index + 1}',
                                    '${(index + 1) * 3}.00');
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
  final String price;
  final String weight; // Добавляем параметр для веса
  final VoidCallback onPressed; // Добавляем колбек для нажатия

  CustomButton({
    required this.title,
    required this.price,
    required this.weight, // Инициализируем параметр веса
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
        double priceFontSize = buttonHeight * 0.1; // 10% от высоты кнопки
        double weightFontSize = buttonHeight * 0.1; // 10% от высоты кнопки

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
                    weight, // Отображаем вес
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: weightFontSize,
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
