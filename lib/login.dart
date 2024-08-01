import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dialog.dart';
import 'firestore.dart';

class Loginpage extends StatelessWidget {
  const Loginpage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rhythm Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  late Map<String, dynamic>? _user;
  String _username = '';
  String _email = '';
  String _password = '';

  int correctStatus = 0; // password = confirmpassword 확인 용도
  int fillStatus = 0; // username, email 채웠는지 확인 용도
  late FToast fToast; //로그인&회원가입 성공 시 toastMessage

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  void register() async {
    try {
      //UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      print('회원가입이 성공했습니다');
      showToastmessage(fToast, '회원가입 성공');
      addDataToFirestore(_username, _email, _password);
    } catch (e) {
      showErrorDialog(context, '회원가입 실패', e);
      print('회원가입이 실패했습니다');
      print(e);
    }
  }

  void login() async {
    try {
      // UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      await _auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      print('로그인이 성공했습니다');

      //로그인 성공 시 해당 유저의 정보를 firestore에서 가져오기
      _user = await getDataFromFirestore(_email, _password);

      context.pop(_user);
    } catch (e) {
      showErrorDialog(context, '로그인 실패', e);
      print('로그인이 실패했습니다');
      print(e);
    }
  }

  //회원가입 창
  void showRegisterDialog() {
    correctStatus = 0;
    fillStatus = 0;
    double dialogWidth = MediaQuery.of(context).size.width * 0.5;
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _confirmController = TextEditingController();

    showDialog(
        context: context,
        builder: (BuildContext context) {
          //statefulBuilder로 변환 가능한 alertdialog
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            //verifyConfirmPaswword 함수 정의
            //해당 함수가 밖에 있으니 업데이트 X
            //꼭 statefulBuilder 안에 존재해야 함
            void verifyConfirmPassword() {
              setState(() {
                if (_confirmController.text.isEmpty) {
                  correctStatus = 0;
                } else if (_passwordController.text ==
                    _confirmController.text) {
                  correctStatus = 1;
                } else if (_passwordController.text !=
                    _confirmController.text) {
                  correctStatus = -1;
                } else {
                  correctStatus = 0;
                }

                if (_usernameController.text.isNotEmpty &&
                    _emailController.text.isNotEmpty) {
                  fillStatus = 1;
                } else {
                  fillStatus = 0;
                }
              });
            }

            //AlertDialog
            return AlertDialog(
              title: const Text('Register'),
              content: Container(
                width: dialogWidth,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text('Input information'),
                      const SizedBox(height: 5),
                      //입력창(유저 이름)
                      TextField(
                        onChanged: (value) {
                          _username = value;
                        },
                        controller: _usernameController,
                        decoration:
                            const InputDecoration(labelText: 'Username'),
                      ),
                      const SizedBox(height: 5),
                      //입력창(이메일)
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          _email = value;
                        },
                        controller: _emailController,
                        decoration:
                            const InputDecoration(labelText: 'ID/Email'),
                      ),
                      const SizedBox(height: 5),
                      //입력창(비밀번호)
                      TextField(
                        obscureText: true,
                        onChanged: (value) {
                          _password = value;
                        },
                        controller: _passwordController,
                        decoration:
                            const InputDecoration(labelText: 'Password'),
                      ),
                      const SizedBox(height: 5),
                      //입력창(비밀번호 확인)
                      TextField(
                        obscureText: true,
                        onChanged: (value) {
                          verifyConfirmPassword();
                        },
                        controller: _confirmController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          suffixIcon: correctStatus != 0
                              ? Icon(
                                  correctStatus == 1
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color: correctStatus == 1
                                      ? Colors.green
                                      : Colors.red,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //버튼 widget
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Opacity(
                        opacity:
                            (correctStatus == 1 && fillStatus == 1) ? 1.0 : 0.5,
                        child: TextButton(
                          onPressed: (correctStatus == 1 && fillStatus == 1)
                              ? () {
                                  register();
                                  Navigator.of(context).pop();
                                }
                              : null,
                          child: const Text('가입'),
                        )),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        correctStatus = 0;
                      },
                      child: const Text('취소'),
                    ),
                  ],
                ),
              ],
            );
          });
        });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(
            fontFamily: "MaplestoryBold",
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                _email = value;
              },
              decoration: const InputDecoration(labelText: 'ID/Email'),
            ),
            TextField(
              obscureText: true,
              onChanged: (value) {
                _password = value;
              },
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                login();
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(MediaQuery.of(context).size.width * 0.5, 25),
              ),
              child: const Text(
                '로그인',
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontFamily: "MaplestoryLight"),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                showRegisterDialog();
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(MediaQuery.of(context).size.width * 0.5, 25),
              ),
              child: const Text(
                '회원가입',
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontFamily: "MaplestoryLight"),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () {
                showToastmessage(fToast, "test");
                getDataFromFirestore('', '');
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(MediaQuery.of(context).size.width * 0.5, 25),
              ),
              child: const Text(
                'Test',
                style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontFamily: "MaplestoryLight"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
