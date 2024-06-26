import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../models/dataMap.dart';
import '../popup/settingPopup.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late SharedPreferences _prefs;
  late DataMap _dataMap = DataMap({});
  int _settedStartHour = 9;
  int _settedEndHour = 18;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadData();
    initializeService();
  }

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    await service.configure(
      iosConfiguration:
          IosConfiguration(autoStart: true, onForeground: onStart),
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        isForegroundMode: true, //false 시 백그라운드모드
        autoStart: true, //초기화 시 자동 시작
      ),
    );

    //알림 권한 요청
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    FlutterBackgroundService().startService();

    Timer.periodic(const Duration(minutes: 20), (timer) async {
      DateTime now = DateTime.now();
      int hour = now.hour;
      int? startHour = _prefs.getInt('settedStartHour') ?? _settedStartHour;
      int? endHour = _prefs.getInt('settedEndHour') ?? _settedEndHour;

      // 설정된 시간에만 푸시 알림
      if (hour >= startHour && hour < endHour) {
        flutterLocalNotificationsPlugin.show(
          1,
          '안약 넣을 시간👀🕒',
          '인공눈물 넣을 시간이에용',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );
      }
    });
  }

  static Future<void> onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();
    String? jsonData = _prefs.getString('dataMap');
    int? settedStartHour = _prefs.getInt('settedStartHour');
    int? settedEndHour = _prefs.getInt('settedEndHour');

    if (jsonData != null) {
      setState(() {
        _dataMap = DataMap.fromJson(jsonDecode(jsonData));
      });
    } else {
      setState(() {
        _dataMap = DataMap({});
      });
    }

    if (settedStartHour != null && settedEndHour != null) {
      setState(() {
        _settedStartHour = settedStartHour;
        _settedEndHour = settedEndHour;
      });
    }
  }

  String changeTime(value) {
    return value < 10 ? '0${value}' : '${value}';
  }

  Future<void> _addData(Map<String, dynamic> map) async {
    DateTime date = DateTime.now();
    String formattedDate = '${date.year}/${date.month}/${date.day}';
    String formattedTime =
        '${changeTime(date.hour)}:${changeTime(date.minute)}:${changeTime(date.second)}';
    String itemType = map['type']?.toString() ?? '';
    DataItem newData = DataItem(itemType, formattedTime);

    setState(() {
      // 현재 날짜 객체가 존재하면 배열에 추가, 존재하지 않으면 현재 날짜로 객체 생성
      if (_dataMap.dataMap.containsKey(formattedDate)) {
        _dataMap.dataMap[formattedDate]?.insert(0, newData as DataItem);
      } else {
        _dataMap.dataMap[formattedDate] = [newData as DataItem];
      }
    });

    String jsonData = jsonEncode(_dataMap.toJson());
    await _prefs.setString('dataMap', jsonData);
  }

  Future<void> _removeData() async {
    await _prefs.remove('dataMap');
    await _loadData();
  }

  Future<void> _saveSettedHour(startHour, endHour) async {
    setState(() {
      _settedStartHour = startHour;
      _settedEndHour = endHour;
    });
    await _prefs.setInt('settedStartHour', startHour);
    await _prefs.setInt('settedEndHour', endHour);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('안약 넣을 시간👀🕒'), actions: <Widget>[
          PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                        child: TextButton(
                            child: const Text('설정'),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return SettingPopup(
                                    initialStartHour: _settedStartHour,
                                    initialEndHour: _settedEndHour,
                                    onSave: (startHour, endHour) =>
                                        _saveSettedHour(startHour, endHour),
                                  );
                                },
                              );
                            })),
                    PopupMenuItem(
                      child: TextButton(
                        child: const Text('초기화'),
                        onPressed: _removeData,
                      ),
                    ),
                  ]),
        ]),
        body: ListView(
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
                                    ? Icon(Icons.medication, color: Colors.grey)
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
