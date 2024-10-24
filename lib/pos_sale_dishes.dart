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
  Map<int, int> buttonClickCounts = {};

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
      buttonClickCounts[buttonIndex] = (buttonClickCounts[buttonIndex] ?? 1) - 1;
      records[index][recordIndex]['count'] -= 1;

      if (records[index][recordIndex]['count'] <= 0) {
        records[index].removeAt(recordIndex);
      }

      if (records[index].isEmpty) {
        records.removeAt(index);
        if (_tabController.length > 1) {
          _tabController = TabController(length: _tabController.length - 1, vsync: this);
          if (_tabController.index >= index) {
            _tabController.index = _tabController.index > 0 ? _tabController.index - 1 : 0;
          }
        }
      }
    });
  }

  void _incrementButtonClick(int buttonIndex) {
    setState(() {
      buttonClickCounts[buttonIndex] = (buttonClickCounts[buttonIndex] ?? 0) + 1;
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
                    Expanded(child: Container(height: firstRowHeight, color: Colors.red, child: Center(child: Text('1/3', style: TextStyle(color: Colors.white))))),
                    Expanded(child: Container(height: firstRowHeight, color: Colors.green, child: Center(child: Text('1/3', style: TextStyle(color: Colors.white))))),
                    Expanded(child: Container(height: firstRowHeight, color: Colors.blue, child: Center(child: Text('1/3', style: TextStyle(color: Colors.white))))),
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
                              tabs: List.generate(_tabController.length, (index) {
                                return Tab(text: 'Вкладка ${index + 1}');
                              }),
                            ),
                            Expanded(
                              child: CustomTabBarView(
                                tabController: _tabController,
                                records: records,
                                onRemoveRecord: _removeRecord
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

  CustomTabBarView({
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

  CustomListView({
    required this.records,
    required this.onRemoveRecord,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, recordIndex) {
        return ListTile(
          title: Text('Кнопка: ${records[recordIndex]['title']}'),
          subtitle: Text('Цена: ${records[recordIndex]['price']}, Количество: ${records[recordIndex]['count']}'),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
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
                      onButtonPressed('Кнопка $buttonIndex', '${buttonIndex * 3}.00', buttonIndex);
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
                                           width: MediaQuery.of(context).size.width * 0.66 / 4,
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
                if (buttonTabController.index < buttonTabController.length - 1) {
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
  final int clickCount;

  CustomButton({
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
