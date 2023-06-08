import 'package:drp31/main.dart';
import 'package:flutter/material.dart';

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

  void onItemTapped(int index) {
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
        ],
        iconSize: 40,
        currentIndex: 1,
        selectedItemColor: Colors.deepPurple,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => MyHomePage(title: 'Ascent')));
                  break;
            case 1:
              Navigator.push(context, MaterialPageRoute(builder: (context) =>
                  LeaderboardPage(totalPoints: widget.totalPoints)));
          }
          //onItemTapped;
        }
    ),
    );
  }
}