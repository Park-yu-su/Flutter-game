import 'package:flutter/material.dart';

Future<int> makeSettingdialog(BuildContext context, bool _loginCheck) async {
  final result = await showDialog<int>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Select Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('난이도를 선택해주세요'),
            if (!_loginCheck)
              const Text(
                '로그인하지 않아 기록 저장이 불가능합니다',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 10.0,
                ),
              ),
          ],
        ),
        actions: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(1);
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize:
                        Size(MediaQuery.of(context).size.width * 0.4, 25),
                  ),
                  child: const Text('Easy'),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(2);
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize:
                        Size(MediaQuery.of(context).size.width * 0.4, 25),
                  ),
                  child: const Text('Normal'),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(3);
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize:
                        Size(MediaQuery.of(context).size.width * 0.4, 25),
                  ),
                  child: const Text('Hard'),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(0);
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize:
                        Size(MediaQuery.of(context).size.width * 0.3, 25),
                  ),
                  child: const Text('취소'),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );

  return result ?? 0;
}
