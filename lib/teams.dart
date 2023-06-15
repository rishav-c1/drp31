import 'package:drp31/main.dart';
import 'package:drp31/userGoal.dart';
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

  void addTaskToTeam(Team team) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String taskName = '';

        return AlertDialog(
          title: Text('Add Task to ${team.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => taskName = value,
                decoration: const InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                onChanged: (value) => taskName = value,
                decoration: const InputDecoration(labelText: 'Points'),
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
                if (taskName.isNotEmpty) {
                  String teamId = team.name.replaceAll(' ', '').toLowerCase();

                  // Add the task to the team's list of tasks
                  await db.collection('teams').doc(teamId).update({
                    'tasks': FieldValue.arrayUnion([taskName])
                  });

                  // Fetch the updated list of teams after adding the task
                  fetchTeams();

                  // Show a success message
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Task added successfully'),
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


  void fetchTeams() async {
    final teamSnapshot = await db.collection('teams').where('users', arrayContains: UserPage.userId).get();
    setState(() {
      teams = teamSnapshot.docs.map((doc) {
        final data = doc.data();
        final name = data['name'] as String?;
        final users = List<String>.from(data['users'] as List<dynamic>? ?? []);
        final tasks = List<String>.from(data['tasks'] as List<dynamic>? ?? []);
        if (name != null) {
          return Team(name: name, users: users, tasks: tasks);
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
      body: FutureBuilder<List<Team>>(
        future: Future.wait(
          teams.map((team) async {
            final usersWithPoints = await Future.wait(
              team.users.map((user) async {
                final points = await getUserPoints(user);
                return User(name: user, points: points);
              }).toList(),
            );

            // Sort users in descending order of points
            usersWithPoints.sort((a, b) => b.points.compareTo(a.points));

            return Team(
              name: team.name,
              users: usersWithPoints.map((user) => user.name).toList(),
              tasks: team.tasks,
            );
          }).toList(),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            );
          } else {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final sortedTeams = snapshot.data!;
              return ListView.builder(
                itemCount: sortedTeams.length,
                itemBuilder: (context, index) {
                  final team = sortedTeams[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      leading: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => addTaskToTeam(team),
                      ),
                      title: Text(
                        team.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      subtitle: Text('${team.memberCount} members'),
                      children: team.users.map((user) => FutureBuilder<int>(
                        future: getUserPoints(user),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final userPoints = snapshot.data;
                              return ListTile(
                                leading: Text('${team.users.indexOf(user) + 1}', style: const TextStyle(fontFamily: 'Roboto', fontSize: 17, color: Colors.deepPurple)),
                                title: Text(user, style: const TextStyle(fontFamily: 'Roboto', fontSize: 17, fontWeight: FontWeight.bold)),
                                subtitle: Text('$userPoints Points', style: const TextStyle(fontFamily: 'Roboto', fontSize: 16, color: Colors.black54)),
                                tileColor: user == UserPage.userId ? Colors.deepPurple[50] : Colors.white,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const UserGoalPage(),
                                  ),
                                ),
                              );
                            }
                          }
                        },
                      )).toList(),
                    ),
                  );
                },
              );
            }
          }
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
            icon: Icon(Icons.people),
            label: 'Teams',
          ),
        ],
        currentIndex: 2,
        selectedItemColor: Colors.deepPurple,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const MyHomePage()));
              break;
            case 1:
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => const GoalPage()));
              break;
          }
        },
      ),
    );
  }
}