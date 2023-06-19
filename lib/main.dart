import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'goals.dart';
import 'weeklyRecap.dart';
import 'teams.dart';
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
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ascent',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0, // flat design
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Remember',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10.0),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'Rate your ',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'easiest goals',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' 100 points, and your ',
                    ),
                    TextSpan(
                      text: 'hardest goals',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' 500 points. Anything else is in between!',
                    ),
                  ],
                ),
              ),


              const SizedBox(height: 20.0),
              const SizedBox(height: 20.0),
              const SizedBox(height: 20.0),
              const SizedBox(height: 20.0),

              const SizedBox(
                height: 20.0,
              ),

              const CircleAvatar(
                backgroundColor: Colors.deepPurple,
                radius: 60,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                'Welcome back ${UserPage.userId}!',
                style: const TextStyle(
                  fontSize: 30,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Here\'s what you\'ve missed...',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Roboto',
                ),
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
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
            icon: Icon(Icons.group),
            label: 'Teams',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        onTap: (int index) {
          switch (index) {
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GoalPage()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TeamsPage()),
              );
              break;
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WeeklyRecapPage(),
            ),
          );
        },
        label: const Text('Weekly Recap'),
        icon: const Icon(Icons.book),
        backgroundColor: Colors.deepPurple,
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
        title: const Text('Ascent'),
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
                  labelText: 'Please enter your username',
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final id = userController.text;
                  addUser(id);
                  userController.clear();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyHomePage(),
                    ),
                  );
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
