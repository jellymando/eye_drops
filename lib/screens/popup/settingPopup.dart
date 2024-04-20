import 'package:flutter/material.dart';

class SettingPopup extends StatefulWidget {
  final int initialStartHour;
  final int initialEndHour;
  final void Function(int, int) onSave;

  const SettingPopup({
    super.key,
    required this.initialStartHour,
    required this.initialEndHour,
    required this.onSave,
  });

  @override
  State<SettingPopup> createState() => _SettingPopupState();
}

class _SettingPopupState extends State<SettingPopup> {
  late int _settedStartHour;
  late int _settedEndHour;
  late bool? _isSettingError = false;

  @override
  void initState() {
    super.initState();
    _settedStartHour = widget.initialStartHour;
    _settedEndHour = widget.initialEndHour;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('푸시 알림 시간 설정'),
      content: Container(
        height: 140,
        child: Column(
          children: <Widget>[
            Row(children: [
              Text('시작시간'),
              SizedBox(width: 20),
              DropdownButton<int>(
                value: _settedStartHour,
                onChanged: (int? newValue) {
                  setState(() {
                    _settedStartHour = newValue!;
                  });
                },
                items: List.generate(
                  24,
                  (index) => DropdownMenuItem<int>(
                    value: index,
                    child: Text(index < 10
                        ? '0${(index).toString()}'
                        : (index).toString()),
                  ),
                ),
              ),
            ]),
            Row(
              children: [
                Text('종료시간'),
                SizedBox(width: 20),
                DropdownButton<int>(
                  value: _settedEndHour,
                  onChanged: (int? newValue) {
                    setState(() {
                      _settedEndHour = newValue!;
                    });
                  },
                  items: List.generate(
                    24,
                    (index) => DropdownMenuItem<int>(
                      value: index,
                      child: Text(index < 10
                          ? '0${(index).toString()}'
                          : (index).toString()),
                    ),
                  ),
                ),
              ],
            ),
            if (_isSettingError == true)
              Column(
                children: [
                  SizedBox(height: 15),
                  const Text(
                    '시작시간은 종료시간보다 작아야 합니다.',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('닫기'),
        ),
        TextButton(
          onPressed: () {
            if (_settedStartHour >= _settedEndHour) {
              setState(() {
                _isSettingError = true;
              });
            } else {
              widget.onSave(_settedStartHour, _settedEndHour);
              Navigator.of(context).pop();
            }
          },
          child: Text('저장'),
        ),
      ],
    );
  }
}
