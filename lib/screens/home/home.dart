import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/dataMap.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late SharedPreferences _prefs;
  late DataMap _dataMap = DataMap({});

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    String? jsonData = _prefs.getString('dataMap');
    print(jsonData);
    if (jsonData != null) {
      setState(() {
        _dataMap = DataMap.fromJson(jsonDecode(jsonData));
      });
    } else {
      setState(() {
        _dataMap = DataMap({});
      });
    }
  }

  String changeTime(value) {
    return value < 10 ? '0${value}' : '${value}';
  }

  Future<void> _addData(Map<String, dynamic> map) async {
    DateTime date = DateTime.now();
    String formattedDate = '2024/4/21';
    String formattedTime =
        '${changeTime(date.hour)}:${changeTime(date.minute)}:${changeTime(date.second)}';
    String itemType = map['type']?.toString() ?? '';
    DataItem newData = DataItem(itemType, formattedTime);

    setState(() {
      // 현재 날짜가 존재하면
      if (_dataMap.dataMap.containsKey(formattedDate)) {
        _dataMap.dataMap[formattedDate]?.insert(0, newData as DataItem);
      } else {
        _dataMap.dataMap[formattedDate] = [newData as DataItem];
      }
    });

    String jsonData = jsonEncode(_dataMap.toJson());
    await _prefs.setString('dataMap', jsonData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('안약 넣을 시간👀🕒'),
        ),
        body: Center(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: _dataMap.dataMap.entries.toList().reversed.map((entry) {
              String date = entry.key;
              List<DataItem> items = entry.value;
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.cyan[200],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(date,
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ), // Display the date
                  ...items.map((item) => Column(
                        children: [
                          SizedBox(height: 20),
                          Row(
                            children: <Widget>[
                              item.type == '1'
                                  ? Icon(Icons.medication,
                                      color: Colors.pink[300])
                                  : item.type == '2'
                                      ? Icon(Icons.medication,
                                          color: Colors.grey)
                                      : Icon(Icons.water_drop_outlined,
                                          color: Colors.lightBlue[300]),
                              SizedBox(width: 7),
                              Text(item.time, style: TextStyle(fontSize: 18)),
                            ],
                          ),
                        ],
                      )),
                  SizedBox(height: 20),
                ],
              );
            }).toList(),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          height: 100,
          color: Colors.white,
          child: IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: IconButton(
                    color: Colors.pink[300],
                    iconSize: 45,
                    icon: const Icon(Icons.medication),
                    onPressed: () => _addData({'type': 1}),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    color: Colors.grey,
                    iconSize: 45,
                    icon: const Icon(Icons.medication),
                    onPressed: () => _addData({'type': 2}),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    color: Colors.lightBlue[300],
                    iconSize: 45,
                    icon: const Icon(Icons.water_drop_outlined),
                    onPressed: () => _addData({'type': 3}),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
