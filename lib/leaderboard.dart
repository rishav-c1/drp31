import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String name;
  final int points;

  User({required this.name, required this.points});
}

class LeaderboardPage extends StatefulWidget {
  final int totalPoints;

  const LeaderboardPage({required this.totalPoints});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPage();
}

class _LeaderboardPage extends State<LeaderboardPage> {
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

  @override
  Widget build(BuildContext context) {
    users.add(User(name: 'Me', points: widget.totalPoints));
    users.sort((a, b) => b.points.compareTo(a.points));
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: Text('${index + 1}'), // Rank number
            title: Text(user.name),
            subtitle: Text('${user.points} points'),
          );
        },
      ),
    );
  }

}