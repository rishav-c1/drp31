import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drp31/weeklyRecap.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'addGoal.dart';
import 'goals.dart';
import 'leaderboard.dart';
import 'weeklyRecap.dart';
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
        home: UserPage());
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({Key ? key}) : super(key:key);

  @override
  State<MyHomePage> createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ascent'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text('Hello ${UserPage.userId}'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "btn2",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WeeklyRecapPage(),
            ),
          );
        },
        backgroundColor: Colors.deepPurple,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Weekly Recap'),
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
        currentIndex: 0,
        selectedItemColor: Colors.deepPurple,
        onTap: (int index) {
          switch (index) {
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GoalPage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LeaderboardPage()),
              );
              break;
          }
        },
      ),
    );
  }
}

class UserPage extends StatefulWidget {
  static String userId = '';

  static void setUserId(String id) {
    userId = id;
  }

  @override
  _UserPage createState() => _UserPage();
}

class _UserPage extends State<UserPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final userController = TextEditingController();

  @override
  void dispose() {
    userController.dispose();
    super.dispose();
  }

  void addUser(String id) async {
    if (id.isNotEmpty) {
      UserPage.setUserId(id);
      final userRef = FirebaseFirestore.instance.collection('users').doc(id);
      final snapshot = await userRef.get();
      if (!snapshot.exists) {
        await userRef.set({'points': 0, 'completed': 0});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ascent'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: userController,
                decoration: InputDecoration(
                  labelText: 'Enter your username',
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final id = userController.text;
                  addUser(id);
                  userController.clear();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyHomePage(),
                        ),
                      );
                  },
                child: Text('Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
