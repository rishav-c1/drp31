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
  final String userId;

  const MyHomePage({required this.userId});

  @override
  State<MyHomePage> createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {

  Future<String> getUserName(String userId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userRef.get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      final name = data['name'];
      return name;
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getUserName(widget.userId),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot.data ?? 'No name'),
            ),
            body: Center(
              child: Text('Hello ${snapshot.data}'),
            ),
            floatingActionButton: FloatingActionButton.extended(
              heroTag: "btn2",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeeklyRecapPage(userId: widget.userId),
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
                      MaterialPageRoute(builder: (context) => GoalPage(userId: widget.userId)),
                    );
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
      },
    );
  }
}

class UserPage extends StatefulWidget {
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

  Future<String> addUser(String name) async {
    if (name.isNotEmpty) {
      final docRef = await db.collection('users').add({'name': name, 'points': 0, 'completed': 0});
      return docRef.id;
    } else {
      return '';
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
                  labelText: 'Enter your name',
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final name = userController.text;
                  addUser(name).then((userId) {
                    userController.clear();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyHomePage(userId: userId),
                      ),
                    );
                  });
                },
                child: Text('Create User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
