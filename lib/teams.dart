import 'package:drp31/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'goals.dart';
import 'leaderboard.dart';

class Team {
  final String name;
  final List<String> users;
  final int memberCount;
  final List<String> tasks; // Added tasks field

  Team({
    required this.name,
    required this.users,
    required this.tasks, // Added tasks field
  }) : memberCount = users.length;
}

class Task {
  final String name;

  Task({required this.name});
}

class TeamsPage extends StatefulWidget {
  const TeamsPage({Key? key}) : super(key: key);

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Team> teams = [];

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
        if (data != null) {
          final name = data['name'] as String?;
          final users = List<String>.from(data['users'] as List<dynamic>? ?? []);
          final tasks = List<String>.from(data['tasks'] as List<dynamic>? ?? []);
          if (name != null) {
            return Team(name: name, users: users, tasks: tasks);
          }
        }
        return null;
      }).where((team) => team != null).cast<Team>().toList();
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
        'users': [UserPage.userId],
        'tasks': [], // Initialize tasks as an empty array
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
          title: const Text('Add Team with Users'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => teamName = value,
                decoration: const InputDecoration(labelText: 'Team Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Team added successfully'),
                  ));

                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void viewTasks(Team team) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tasks for ${team.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (team.tasks.isEmpty)
                const Text('No tasks available')
              else
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: team.tasks.length,
                  itemBuilder: (context, index) {
                    final task = team.tasks[index];
                    return ListTile(
                      title: Text(task),
                    );
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
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
        title: const Text('Teams'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.builder(
        itemCount: teams.length,
        itemBuilder: (context, index) {
          final team = teams[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ExpansionTile(
              title: Text(
                team.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              subtitle: Text('${team.memberCount} members'),
              children: team.users.map((user) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Chip(
                  label: Text(user),
                ),
              )).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTeamWithUsers,
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
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
          }
        },
      ),
    );
  }
}