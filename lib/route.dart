import 'package:go_router/go_router.dart';
import 'package:game_project/game.dart';
import 'package:game_project/home.dart';
import 'package:game_project/login.dart';
import 'package:game_project/score.dart';
import 'package:game_project/logout.dart';

//go_router 사용
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
        path: '/',
        builder: (context, state) {
          return const Home();
        }),
    GoRoute(
        path: '/gameplay',
        builder: (context, state) {
          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>? ?? {};
          final gameLevel = extra['gameLevel'] as int? ?? 0;
          final username = extra['username'] as String? ?? '';
          final email = extra['email'] as String? ?? '';
          final loginCheck = extra['loginCheck'];
          return Gameplay(
              gameLevel: gameLevel,
              username: username,
              email: email,
              loginCheck: loginCheck);
        }),
    GoRoute(
        path: '/login',
        builder: (context, state) {
          return const Loginpage();
        }),
    GoRoute(
        path: '/score',
        builder: (context, state) {
          return const Scorepage();
        }),
    GoRoute(
        path: '/logout/:username',
        builder: (context, state) {
          //state.parameters를 이용해 문자열 보내기(위의 path에 :로 추가)
          return Logoutpage(state.pathParameters['username']);
        }),
  ],
);

/*
//Navigator 사용
final routes = {
  '/': (BuildContext context) => const Home(),
  '/test1': (BuildContext context) => const TestOne(),
  '/test2': (BuildContext context) => const TestTwo(),
  '/test3': (BuildContext context) => const TestThree(),
  '/test4': (BuildContext context) => const TestFour(),
  '/test5': (BuildContext context) => const TestFive(),
};
*/