import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:audioplayers/audioplayers.dart';
import 'setting.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rhythm Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _user;
  String _username = '';
  String _email = '';
  String _password = '';

  bool _loginCheck = false;

  late FToast fToast;

  int _easterCount = 0;
  bool _songTrue = false;
  late AudioPlayer _audioPlayer;

  int gameLevel = 0;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
    _easterCount = 0;
    _songTrue = false;
    _audioPlayer = AudioPlayer();
  }

  //login 이동 + 정보 get
  void navigateLogin(BuildContext context) async {
    final result = await context.push('/login');
    if (result != null) {
      setState(() {
        _user = result as Map<String, dynamic>?;
        _username = _user?['username'];
        _email = _user?['email'];
        _password = _user?['password'];
        _loginCheck = true;
      });
    }
  }

  //logout 이동 + 정보 get
  void navigationLogout(BuildContext context) async {
    final result = await context.push('/logout/$_username');
    if (result != null) {
      setState(() {
        _username = '';
        _email = '';
        _password = '';
        _loginCheck = false;
      });
    }
  }

  void navigationGameplay(BuildContext context, bool _loginCheck) async {
    gameLevel = await makeSettingdialog(context, _loginCheck);
    if (gameLevel != 0) {
      context.push(
        '/gameplay',
        extra: {
          'gameLevel': gameLevel,
          'username': _username,
          'email': _email,
          'loginCheck': _loginCheck,
        },
      );
    }
  }

  //이미지 터치 시 노래 재생
  void easterTouchCount() {
    setState(() {
      _easterCount++;
      print('$_easterCount / $_songTrue');
      if (_easterCount >= 10 && _songTrue == false) play();
    });
  }

  //노래 재생
  void play() async {
    _songTrue = true;
    await _audioPlayer.play(AssetSource(''));
  }

  //노래 정지
  void stop() {
    _audioPlayer.stop();
    _easterCount = 0;
    _songTrue = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //title: 'Main page',

      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.07,
        color: Color.fromARGB(255, 207, 202, 202),
        //child: TabBar(),
      ),

      body: Center(
        child: Column(
          //세로 정렬 (자식은 children)
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              color: Colors.white,
              child: const Text(
                "하루만 기다리면!",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontFamily: "MaplestoryBold",
                ),
              ),
            ),
            const SizedBox(height: 5.0),
            GestureDetector(
              onTap: easterTouchCount,
              child: Image.asset(
                
                'assets/images/drum.gif',
                width: 400,
                height: 200,
              ),
            ),
            const SizedBox(height: 5.0),
            const Text(
              "무엇인가 나와요!",
              style: TextStyle(
                color: Colors.red,
                fontSize: 30,
                fontFamily: "MaplestoryBold",
              ),
            ),
            const SizedBox(height: 5.0),
            Wrap(
              spacing: 5.0, //가로 간격
              runSpacing: 2.0, //세로 간격
              alignment: WrapAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    navigationGameplay(context, _loginCheck);
                    stop();
                  },
                  child: const Text(
                    "Game Start",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontFamily: "MaplestoryLight",
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (_loginCheck == false) {
                      navigateLogin(context);
                    } else {
                      navigationLogout(context);
                    }
                    stop();
                    //context.push('/login');
                  },
                  child: _loginCheck == false
                      ? const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontFamily: "MaplestoryLight",
                          ),
                        )
                      : const Text(
                          "Logout",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontFamily: "MaplestoryLight",
                          ),
                        ),
                ),
                TextButton(
                  onPressed: () {
                    context.push('/score');
                    stop();
                  },
                  child: const Text(
                    "Score",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontFamily: "MaplestoryLight",
                    ),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      exit(0);
                    },
                    child: const Text(
                      "Exit",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontFamily: "MaplestoryLight",
                      ),
                    ))
              ],
            ),
            if (_loginCheck == true) SizedBox(height: 15),
            if (_loginCheck == true)
              Text(
                "Welcome $_username",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 35,
                  fontFamily: "MaplestoryBold",
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    //종료될 때 실행
    _audioPlayer.stop();
    super.dispose();
  }
}
