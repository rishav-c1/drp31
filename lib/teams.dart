import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'goals.dart';
import 'joinTeam.dart';
import 'leaderboard.dart';
import 'main.dart';

class Team {
  final String id;
  final String name;
  final List<String> users;

  Team({required this.id, required this.name, required this.users});
}

Future<List<Team>> fetchTeams() async {
  final teamsRef = FirebaseFirestore.instance.collection('teams');
  final snapshot = await teamsRef.get();

  final teams = snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    final id = doc.id;
    final name = data['name'] as String;
    final users = List<String>.from(data['users']);
    return Team(id: id, name: name, users: users);
  }).toList();

  return teams;
}

class TeamsPage extends StatefulWidget {

  const TeamsPage({Key ? key}) : super(key:key);

  @override
  State<TeamsPage> createState() => _TeamsPage();
}

class _TeamsPage extends State<TeamsPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Team> teams = [];
  late int userPoints = 0;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchTeams().then((fetchedTeams) {
      setState(() {
        teams = fetchedTeams;
      });
    });
    loadUserPoints();
  }

  void loadUserPoints() async {
    userPoints = await getUserPoints(UserPage.userId);
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
        title: Text('Teams'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          return ListTile(
            title: Text(team.name),
            subtitle: Text('Users: ${team.users.length}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JoinTeamPage()),
          ).then((_) {
            fetchTeams().then((fetchedTeams) {
              setState(() {
                teams = fetchedTeams;
              });
            });
          });
        },
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add),
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
          BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Teams')
        ],
        currentIndex: 3,
        selectedItemColor: Colors.deepPurple,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => MyHomePage()));
              break;
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