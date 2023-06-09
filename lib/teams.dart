import 'package:drp31/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'goals.dart';
import 'leaderboard.dart';

class Team {
  final String name;
  final List<String> users;
  final int memberCount;

  Team({
    required this.name,
    required this.users,
  }) : memberCount = users.length;
}

class TeamsPage extends StatefulWidget {
  const TeamsPage({Key? key}) : super(key: key);

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Team> teams = [];
//
  @override
  void initState() {
    super.initState();
    fetchTeams();
  }

  void fetchTeams() async {
    final teamSnapshot = await db.collection('teams').where('users', arrayContains: UserPage.userId).get();
    setState(() {
      teams = teamSnapshot.docs.map((doc) {
        final data = doc.data();
        final name = data['name'] as String;
        final users = List<String>.from(data['users']);
        return Team(name: name, users: users);
      }).toList();
    });
  }

  void joinTeam(String teamName) async {
    String teamId = teamName.replaceAll(' ', '').toLowerCase();

    // Check if the team exists in the database
    final teamRef = db.collection('teams').doc(teamId);
    final teamSnapshot = await teamRef.get();

    if (teamSnapshot.exists) {
      // Team exists, add the user to the team's list of users
      
      await teamRef.update({
        'users': FieldValue.arrayUnion([UserPage.userId])
      });
    } else {
      // Team doesn't exist, create a new team with the user
      await teamRef.set({
        'name': teamName,
        'users': [UserPage.userId]
      });
    }

    // Fetch the updated list of teams after joining
    fetchTeams();
  }

  void addTeamWithUsers() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String teamName = '';

        return AlertDialog(
          title: Text('Add Team with Users'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => teamName = value,
                decoration: InputDecoration(labelText: 'Team Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (teamName.isNotEmpty) {
                  String teamId = teamName.replaceAll(' ', '').toLowerCase();

                  // Create a new team with the user
                  joinTeam(teamName);

                  // Fetch the updated list of teams after adding
                  fetchTeams();

                  // Show a success message
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Team added successfully'),
                  ));

                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
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
            trailing: Text('${team.memberCount} members'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTeamWithUsers,
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
            icon: Icon(Icons.people),
            label: 'Teams',
          ),
        ],
        currentIndex: 3,
        selectedItemColor: Colors.deepPurple,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MyHomePage()));
              break;
            case 1:
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => GoalPage()));
              break;
            case 2:
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => LeaderboardPage()));
              break;
            case 3:
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => TeamsPage()));
              break;
          }
        },
      ),
    );
  }
}