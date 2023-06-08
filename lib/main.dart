import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drp31/feed.dart';
import 'package:drp31/weeklyRecap.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'addGoal.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ascent',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Ascent'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  int totalPoints = 0;
  int goalsCompleted = 0;

  @override
  void dispose() {
    super.dispose();
  }

  void toggleAchieved(String taskId, bool currentStatus, int points) async {
    await db.collection('tasks').doc(taskId).update({'achieved': !currentStatus});
    if (!currentStatus) {
      setState(() {
        totalPoints += points;
        goalsCompleted += 1;
      });
    } else {
      setState(() {
        totalPoints -= points;
        int completed = (goalsCompleted > 0)? goalsCompleted - 1 : 0;
        goalsCompleted = completed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
            Text("My Points: ${totalPoints}pts"),
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
                      final data = task.data() as Map<String, dynamic>;;
                      final isAchieved = data?['achieved'] ?? false;
                      final points = data?['points'] ?? 0;
                      return Card(
                        color: isAchieved ? Colors.green[100] : null,
                        child: ListTile(
                          title: Text(data?['task'] ?? 'Default task'),
                          trailing: TextButton(
                            onPressed: () => toggleAchieved(taskId, isAchieved, points),
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
            const SizedBox(height: 32),
            FloatingActionButton.extended(
              heroTag: "btn2",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WeeklyRecapPage(goalsCompleted: goalsCompleted, totalPoints: totalPoints)),
                );
              },
              backgroundColor: Colors.deepPurple,
              icon: Icon(Icons.add, color: Colors.white),
              label: Text('Weekly Recap'),
            ),
            FloatingActionButton.extended(
              heroTag: "btn3",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Feed()),
                );
              },
              backgroundColor: Colors.deepPurple,
              icon: Icon(Icons.add, color: Colors.white),
              label: Text('Feed'),
            ),
          ],
        ),
      ),
    );
  }
}
