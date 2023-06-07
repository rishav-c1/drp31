import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
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
  final taskController = TextEditingController();
  int totalPoints = 0;

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  void addTask() async {
    String task = taskController.text;
    if (task.isNotEmpty) {
      await db.collection('tasks').add({'task': task, 'achieved': false, 'points': 10});
      taskController.clear();
    }
  }

  void toggleAchieved(String taskId, bool currentStatus, int points) async {
    await db.collection('tasks').doc(taskId).update({'achieved': !currentStatus});
    if (!currentStatus) {
      setState(() {
        totalPoints += points;
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: taskController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Add a goal',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: addTask,
                    icon: const Icon(Icons.send),
                    color: Colors.deepPurple,
                  ),
                ],
              ),
            ),
            Text(
              "My Points: ${totalPoints}pts", // Display total points
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text("Today's Tasks 💪"),
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
          ],
        ),
      ),
    );
  }
}
