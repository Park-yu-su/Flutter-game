import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Logoutpage extends StatelessWidget {
  //this._username = 위치 인자, {super.key} =  이름(명명) 인자
  const Logoutpage(this._username, {super.key});

  final String? _username;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rhythm Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LogoutScreen(username: _username),
    );
  }
}

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key, this.username});

  final String? username;

  @override
  _LogoutScreenState createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  void logout() {
    bool _loginCheck = false;
    context.pop(_loginCheck);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Logout',
          style: TextStyle(
            fontFamily: "MaplestoryBold",
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '\'${widget.username}\'님\n로그아웃 하시겠습니까?',
              style: const TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                  fontFamily: "MaplestoryBold"),
            ),
            const SizedBox(height: 25),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      logout();
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize:
                          Size(MediaQuery.of(context).size.width * 0.35, 25),
                    ),
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontFamily: "MaplestoryLight"),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize:
                          Size(MediaQuery.of(context).size.width * 0.35, 25),
                    ),
                    child: const Text(
                      '취소',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontFamily: "MaplestoryLight"),
                    ),
                  ),
                ]),
          ],
        ),
      ),
    );
  }
}
