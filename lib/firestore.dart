import 'package:cloud_firestore/cloud_firestore.dart';

//register
//회원가입 결과를 firestore -> user에 추가
void addDataToFirestore(
    String _username, String _email, String _password) async {
  await FirebaseFirestore.instance.collection('user').add({
    'username': _username,
    'email': _email,
    'password': _password,
  });
}

//login
//firestore -> user에 있는 정보를 가져오고, 가져온 정보들을 비교해 email, password에 해당하는 유저 정보 반환
Future<Map<String, dynamic>?> getDataFromFirestore(
    String email, String password) async {
  Map<String, dynamic>? user;

  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('user').get();

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    print('ID: ${doc.id} / data: ${doc.data()}');
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    if (data['email'] == email && data['password'] == password) {
      user = data;
      break;
    }
  }

  return user;
}

//score 점수들 가져오기(상위 10위까지만)
Future<List<Map<String, dynamic>>> getScoreFromFirestore(int mylevel) async {
  List<Map<String, dynamic>> scoreList;

  print('-----------------------------');

  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('ranking')
        .where('level', isEqualTo: mylevel)
        .orderBy('score', descending: true)
        .limit(20)
        .get();

    scoreList = querySnapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();

    while (scoreList.length < 20) {
      scoreList.add({'username': '- - - - -', 'score': 0, 'level': mylevel});
    }

    for (Map<String, dynamic> data in scoreList) {
      print('${data['username']} / ${data['score']} / ${data['level']}');
    }
  } catch (e) {
    print('${e}');
    return [];
  }

  return scoreList;
  /*
  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    print('${data['username']} / ${data['score']}');
  }
  */
}

//game update
void addResultToFirestore(String username, int score, int level) async {
  await FirebaseFirestore.instance.collection('ranking').add({
    'username': username,
    'score': score,
    'level': level,
  });
}
