import 'package:drp31/main.dart';
import 'package:drp31/teams.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'goals.dart';

class User {
  final String name;
  final int points;

  User({required this.name, required this.points});
}

class LeaderboardPage extends StatefulWidget {

  const LeaderboardPage({Key? key}):super(key:key);

  @override
  State<LeaderboardPage> createState() => _LeaderboardPage();
}

class _LeaderboardPage extends State<LeaderboardPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  int selectedIndex = 0;
  final List<User> users = [
    User(name: 'User 1', points: 150),
    User(name: 'User 2', points: 200),
    User(name: 'User 3', points: 100),
    User(name: 'User 4', points: 300),
  ];

  @override
  void dispose() {
    super.dispose();
  }
  Future<int> getUserPoints(String userId) async {
    final userRef = db.collection('users').doc(userId);
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
        title: Text('Leaderboard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: db.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          final users = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = data['name'] as String;
            final points = data['points'] as int;
            return User(name: name, points: points);
          }).toList();
          users.sort((a, b) => b.points.compareTo(a.points));
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: Text('${index + 1}'), // Rank number
                title: Text(user.name),
                subtitle: Text('${user.points} points'),
              );
            },
          );
        },
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
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Teams',
          ),
        ],
        currentIndex: 2,
        selectedItemColor: Colors.deepPurple,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => MyHomePage()));
                  break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  GoalPage()));
              break;
            case 3:
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => TeamsPage()));
              break;
          }
        }
    ),
    );
  }
}