import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'dialog.dart';
import 'firestore.dart';

class Gameplay extends StatelessWidget {
  final int gameLevel;
  final String username;
  final String email;
  final bool loginCheck;

  Gameplay(
      {required this.gameLevel,
      required this.username,
      required this.email,
      required this.loginCheck});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rhythm Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(
          gameLevel: gameLevel,
          username: username,
          email: email,
          loginCheck: loginCheck),
    );
  }
}

class GameScreen extends StatefulWidget {
  GameScreen(
      {required this.gameLevel,
      required this.username,
      required this.email,
      required this.loginCheck});

  final int gameLevel;
  final String username;
  final String email;
  final bool loginCheck;

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int score = 0;
  int life = 3;
  final Random random = Random();
  String arrow = '⬇️';
  final List<String> arrows = ['⬆️', '⬅️', '➡️', '⬇️'];
  int selectArrow = 0;
  bool musicFinished = false;

  late AudioPlayer _audioPlayer;
  late AnimationController _controller;
  late Animation<Offset> _animation;

  bool isButtonPressed = false;
  double gameSpeed = 4.5; //초기 애니메이션 시간
  int patternCount = 0;

  int? gameLevel;
  String? username;
  String? email;
  bool? loginCheck;

  @override
  void initState() {
    super.initState();
    gameLevel = widget.gameLevel;
    username = widget.username;
    email = widget.email;
    loginCheck = widget.loginCheck;
    print('$gameLevel / $username / $email');
    _audioPlayer = AudioPlayer();
    musicFinished = false;

    if (gameLevel == 1) {
      gameSpeed = 5.0;
    } else if (gameLevel == 2) {
      gameSpeed = 4.5;
    } else if (gameLevel == 3) {
      gameSpeed = 4.0;
    }

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.completed) {
        musicFinished = true;
        gameStop();
        showGameOverDialog();
      }
    });

    play();

    //화살표 애니메이션
    _controller = AnimationController(
      duration: Duration(seconds: gameSpeed.toInt()), //애니메이션 속도
      vsync: this,
    );
    _animation = Tween<Offset>(
      begin: Offset(-1.0, 0.0),
      end: Offset(1.0, 0.0),
    ).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          print("contact_finishLine");
          if (!isButtonPressed) {
            setState(() {
              life -= 1;
            });

            if (life == 0) {
              gameStop();
              showGameOverDialog();
            }
          }
          if (life > 0) {
            resetAnimation();
          }
        }
      });

    generateArrow();
    _controller.repeat();
    //애니메이션 속도
  }

  void speedUp() {
    setState(() {
      switch (gameLevel) {
        case 1:
          if (gameSpeed > 1.5) {
            if (gameSpeed > 3.5)
              gameSpeed -= 0.07; //속도 0.07씩 증가
            else
              gameSpeed -= 0.03; //속도 0.03씩 증가
          }
          gameSpeed = max(gameSpeed, 2.3); // 2.0
          break;

        case 2:
          if (gameSpeed > 1.0) {
            if (gameSpeed > 3.0)
              gameSpeed -= 0.1; //속도 0.1씩 증가
            else
              gameSpeed -= 0.05; //속도 0.05씩 증가
          }
          gameSpeed = max(gameSpeed, 2.1); //1.5
          break;

        case 3:
          if (gameSpeed > 0.5) {
            if (gameSpeed > 3.0)
              gameSpeed -= 0.15; //속도 0.15씩 증가
            else
              gameSpeed -= 0.07; //속도 0.07씩 증가
          }
          gameSpeed = max(gameSpeed, 1.8); //1.0
          break;

        default:
          break;
      }

      _controller.duration = Duration(
          seconds: gameSpeed.toInt(),
          milliseconds: ((gameSpeed - gameSpeed.toInt()) * 1000)
              .toInt()); // millisecond 이용해 실수값으로 duration 업데이트

      print("Speed up : $gameSpeed");
    });
  }

  void gameStop() {
    setState(() {
      _controller.stop(); // 애니메이션 정지
    });

    _audioPlayer.stop();
  }

  void generateArrow() {
    setState(() {
      selectArrow = random.nextInt(4);
      arrow = arrows[selectArrow];
    });
    _controller.forward(from: 0.0);
  }

  void resetAnimation() {
    setState(() {
      isButtonPressed = false;
      generateArrow();
      print('repeat');
    });
  }

  void onPressed(int compare) {
    setState(() {
      if (_controller.value > 0.50) {
        //판정선 약 0.625가 중앙 기준
        isButtonPressed = true;
        print(_controller.value);

        //perfect
        if (_controller.value > 0.62 &&
            _controller.value < 0.63 &&
            compare == selectArrow) {
          score += 3;
          showCustomToast(context, 'PERFECT');
          speedUp();
        }

        //great
        else if (_controller.value > 0.61 &&
            _controller.value < 0.65 &&
            compare == selectArrow) {
          score += 2;
          showCustomToast(context, 'GREAT');
          speedUp();
        }

        //good
        else if (_controller.value > 0.55 &&
            _controller.value < 0.67 &&
            compare == selectArrow) {
          score += 1;
          showCustomToast(context, 'GOOD');
          speedUp();
        } else {
          life--;
          if (life == 0) {
            gameStop();
            showGameOverDialog();
          }
        }

        if (life > 0) {
          resetAnimation();
        }
      }
    });
  }

  //게임오버/클리어 표시
  void showGameOverDialog() {
    int plusScore = 0;
    if (life > 0) {
      plusScore += life * 50;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: musicFinished
              ? const Text('Game Clear')
              : const Text('Game Over'),
          content: loginCheck == true
              ? Text(
                  'Your score: $score\nLife score: $plusScore\nTotal score: ${score + plusScore}\n$username님 기록을 저장하시겠습니까?')
              : Text('Your score: $score'),
          actions: loginCheck == true
              ? <Widget>[
                  TextButton(
                    onPressed: () {
                      addResultToFirestore(
                          username!, score + plusScore, gameLevel!);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('네'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('아니요'),
                  ),
                ]
              : <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      resetGame();
                    },
                    child: const Text('Restart'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Exit'),
                  ),
                ],
        );
      },
    );
  }

  //게임 다시 시작
  void resetGame() {
    setState(() {
      score = 0;
      life = 3;
      play();
      generateArrow();
      _controller.repeat();
    });
  }

  //음악 재생
  void play() async {
    if (gameLevel == 1) {
      await _audioPlayer.play(AssetSource(''));
    } else if (gameLevel == 2) {
      await _audioPlayer.play(AssetSource(''));
    } else {
      await _audioPlayer.play(AssetSource(''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Rhythm Game',
          style: TextStyle(
            fontFamily: "MaplestoryBold",
          ),
        ),
      ),
      body: Stack(
        children: [
          //배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/blue.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: 60),
              child: Container(
                width: MediaQuery.of(context).size.width * 1.0,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.7),
                  border: Border.all(
                    color: Colors.blue,
                    width: 4.0,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                margin: EdgeInsets.symmetric(horizontal: 20.0), // 좌우 여백 추가
              ),
            ),
          ),

          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: 60,
                  left: MediaQuery.of(context).size.width * 0.50 - 1),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color.fromARGB(181, 3, 136, 245),
                    width: 4.0,
                  ),
                ),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4.0,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 35,
                        height: 3.5,
                        color: Colors.white,
                      ),
                      Container(
                        width: 3.5,
                        height: 35,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              return SlideTransition(
                position: _animation,
                child: child,
              );
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: Center(
                  child: Text(
                    arrow,
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),

          //Score
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 60.0, left: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: 30,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Score: $score',
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontFamily: "MaplestoryBold",
                    ),
                  ),
                ],
              ),
            ),
          ),

          //Life
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 20.0, left: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 30,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Life: $life',
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontFamily: "MaplestoryBold",
                    ),
                  ),
                ],
              ),
            ),
          ),

          //Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 120.0,
              ),
              child: ElevatedButton(
                onPressed: () {
                  onPressed(0);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size(80, 80),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  backgroundColor: Colors.white,
                ),
                child: const Text(
                  '⬆️',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 50,
                  ),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 70.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, //수평 정렬
                crossAxisAlignment: CrossAxisAlignment.center, //수직 정렬
                children: [
                  ElevatedButton(
                    onPressed: () {
                      onPressed(1);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      '⬅️',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 50,
                      ),
                    ),
                  ),

                  //버튼 사이 간격
                  const SizedBox(
                    width: 120,
                    height: 10,
                  ),

                  ElevatedButton(
                    onPressed: () {
                      onPressed(2);
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 5),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      '➡️',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 50,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 10.0,
              ),
              child: ElevatedButton(
                onPressed: () {
                  onPressed(3);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size(80, 80),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  backgroundColor: Colors.white,
                ),
                child: const Text(
                  '⬇️',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 50,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    //종료될 때 실행
    _controller.dispose();
    _audioPlayer.stop();
    super.dispose();
  }
}
