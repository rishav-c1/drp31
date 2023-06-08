import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'addGoal.dart';
import 'leaderboard.dart';
import 'main.dart';

class GoalPage extends StatefulWidget {
  final String userId;

  const GoalPage({required this.userId});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void dispose() {
    super.dispose();
  }

  void toggleAchieved(String taskId, String userId, bool currentStatus, int points) async {
    await db.collection('tasks').doc(taskId).update({'achieved': !currentStatus});
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userRef.get();
    final data = snapshot.data() as Map<String, dynamic>;
    int totalPoints = data['points'];
    int completed = data['completed'];
    if (!currentStatus) {
      setState(() {
        totalPoints += points;
        completed += 1;
      });
    } else {
      setState(() {
        totalPoints -= points;
        int completed2 = (completed > 0)? completed - 1 : 0;
        completed = completed2;
      });
    }
    await db.collection('users').doc(taskId).update({'points': totalPoints, 'completed': completed});
  }

  Future<int> getUserPoints(String userId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userRef.get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      final points = data['points'];
      return points;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('My Goals'),
        backgroundColor: Colors.deepPurple,
    ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Text(
            "Today's Tasks 💪",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          Text("My Points: ${getUserPoints(widget.userId)}pts"),
          const SizedBox(height: 32),
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: () {
              Navigator.push(
                context,
                  MaterialPageRoute(builder: (context) => AddGoalPage()),
              );
            },
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
            stream: db.collection('tasks').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              final List<DocumentSnapshot> documents = snapshot.data!.docs;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final task = documents[index];
                  final taskId = task.id;
                  final data = task.data() as Map<String, dynamic>;
                  final isAchieved = data?['achieved'] ?? false;
                  final points = data?['points'] ?? 0;
                  final userId = data['userId'];
              return Card(
                color: isAchieved ? Colors.green[100] : null,
                child: ListTile(
                  title: Text(data?['task'] ?? 'Default task'),
                  trailing: TextButton(
                    onPressed: () => toggleAchieved(taskId, userId, isAchieved, points),
                    child: Text(
                      isAchieved ? 'Achieved  +${points}pts' : 'Mark Achieved',
                      style: TextStyle(color: isAchieved ? Colors.green : Colors.black),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
    const SizedBox(height: 32)
          ],
    ),
    ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.deepPurple,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => MyHomePage(userId: widget.userId)));
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LeaderboardPage(userId: widget.userId)),
              );
              break;
          }
        },
      ),
    );
  }
}