import 'package:flutter/material.dart';
import 'firestore.dart';

class Scorepage extends StatelessWidget {
  const Scorepage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rhythm Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ScoreScreen(),
    );
  }
}

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Ranking',
          style: TextStyle(
            fontFamily: "MaplestoryBold",
          ),
        ),
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(text: 'Easy'),
            Tab(text: 'Normal'),
            Tab(text: 'Hard'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          buildRankingWidget(1),
          buildRankingWidget(2),
          buildRankingWidget(3),
        ],
      ),
    );
  }

  Widget buildRankingWidget(int level) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: getScoreFromFirestore(level),
        builder: (context, snapshot) {
          //로딩중(정보 가져오기)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          //Error 발생
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
            //Data가 존재하지 않을 때
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Fail to get Data'));
          }
          //정상 리턴
          else {
            List<Map<String, dynamic>> scoreData = snapshot.data!;

            return ListView.builder(
                padding: const EdgeInsets.all(5),
                itemCount: scoreData.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (index < 3)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.emoji_events,
                                color: index == 0
                                    ? Colors.amber
                                    : index == 1
                                        ? Color.fromARGB(255, 169, 167, 167)
                                        : Color.fromARGB(255, 192, 76, 23),
                                size: 25,
                              ),
                              SizedBox(width: 5),
                            ],
                          ),
                        if (index >= 3)
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.emoji_events,
                                color: Colors.transparent,
                                size: 25,
                              ),
                              SizedBox(width: 5),
                            ],
                          ),
                        Container(
                          color: Colors.transparent,
                          width: 40,
                          child: Text(
                            '${(index + 1).toString().padLeft(2, ' ')}',
                            style: const TextStyle(
                              fontFamily: 'MaplestoryBold',
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(
                      scoreData[index]['username'] ?? 'Unknown',
                      style: const TextStyle(
                        fontFamily: 'MaplestoryLight',
                        fontSize: 25,
                      ),
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.only(right: 30.0),
                      child: Text(
                        '${scoreData[index]['score'].toString()}점',
                        style: const TextStyle(
                          fontFamily: 'MaplestoryLight',
                          fontSize: 25,
                        ),
                      ),
                    ),
                  );
                });
          }
        });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}
