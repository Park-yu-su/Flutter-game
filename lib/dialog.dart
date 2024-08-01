import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

//toast message 출력(중앙 하단)
//fToast : FToast 객체 / content : toastmessage에 출력할 내용
void showToastmessage(FToast fToast, String content) {
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.grey,
    ),
    child: Text(
      content,
      style: const TextStyle(
          fontSize: 15, color: Colors.black, fontFamily: "MaplestoryLight"),
    ),
  );

  fToast.showToast(
    child: toast,
    toastDuration: const Duration(seconds: 1),
  );
  print('toastMessage out');
}

//판정 결과를 출력하기 위한 toast message 출력
void showCustomToast(BuildContext context, String content) {
  double _scale = 1.0;

  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: 120, left: MediaQuery.of(context).size.width * 0.50 - 1),
        child: Material(
          color: Colors.transparent,
          child: Transform.scale(
            scale: _scale,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Text(
                '$content',
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontFamily: "MaplestoryBold"),
              ),
            ),
          ),
        ),
      ), //텍스트 위치
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(Duration(milliseconds: 300), () {
    overlayEntry.remove();
  });
}

//에러 창 출력
//context: build시 사용한 BuildContext context / message: 출력할 메시지 / e : 에러 내용
void showErrorDialog(BuildContext context, String message, Object e) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Fail : $message'),
        content: const Text('Sorry!'),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '$e',
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('확인'),
              ),
            ],
          ),
        ],
      );
    },
  );
}
