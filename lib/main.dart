import 'package:flutter/material.dart';
import 'package:game_project/route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/*
firebase 연동 확인
cmd -> firebase login -> firebase projects:list
1. firebase console에 들어가 프로젝트 생성
2. 앱 추가 한 후, build.gradle에서 ID 찾아서 입력
3. SDK 완료 후, json파일을 다운로드 받아 app->main에 저장
4. build.gradle 파일 수정
5. firebase 초기화 하기 -> 웹 추가한 후 연결하고, 해당 SDK 연결
*/

void main() async {
  //App 실행
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //widget의 레이아웃을 정의함
    return MaterialApp.router(
      routerConfig: router,
      title: 'Main page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
