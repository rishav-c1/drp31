import 'package:drp31/main.dart';
import 'package:drp31/userGoal.dart';
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'goals.dart';

class Team {
  final String name;
  final List<String> users;
  final int memberCount;
  final List<Task> tasks; // Tasks are now of type Task

  Team({
    required this.name,
    required this.users,
    required this.tasks, // Tasks are now of type Task
  }) : memberCount = users.length;
}

class Task {
  final String name;
  bool isAchieved;
  final int points;

  Task({required this.name, required this.isAchieved, required this.points});
}

class TeamsPage extends StatefulWidget {
  const TeamsPage({Key? key}) : super(key: key);

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  static FirebaseFirestore db = FirebaseFirestore.instance;
  List<Team> teams = [];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(milliseconds: 500), (Timer t) => getTeams());
  }

  Stream<int> getUserPoints(String userId) {
    return db.collection('users').doc(userId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final points = data['points'];
        return points;
      } else {
        return 0;
      }
    });
  }

  Stream<List<Map<String, dynamic>>> getUserData(Team team) {
    List<Stream<Map<String, dynamic>>> userStreams = team.users.map((user) {
      return getUserPoints(user).map((points) {
        return {'user': user, 'points': points};
      });
    }).toList();

    // Convert List<Stream<Map<String, dynamic>>> to Stream<List<Map<String, dynamic>>>
    return CombineLatestStream.list(userStreams).map((usersWithPoints) {
      List<Map<String, dynamic>> modifiableList = List.from(usersWithPoints);
      modifiableList.sort((a, b) => b['points'].compareTo(a['points']));
      return modifiableList;
    });
  }

  void addTaskToTeam(Team team) {
    print("addTaskToTeam() called");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController taskNameController = TextEditingController();
        TextEditingController pointsController = TextEditingController();

        return AlertDialog(
          title: Text('Add Goal to ${team.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskNameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
              ),
              TextField(
                controller: pointsController,
                decoration: const InputDecoration(labelText: 'Points'),
                keyboardType: TextInputType.number,
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
                print("Task Name: ${taskNameController.text}, Points: ${pointsController.text}");
                String taskName = taskNameController.text;
                int? points = int.tryParse(pointsController.text);
                if (taskName.isNotEmpty && points != null) {

                  // Get the current tasks
                  final currentTasks = team.tasks;

                  // Add the new task
                  currentTasks.add(Task(name: taskName, isAchieved: false, points: points));

                  // Update the tasks in Firestore
                  await db.collection('teams').doc(team.name).update({
                    'tasks': currentTasks.map((task) => {
                      'name': task.name,
                      'isAchieved': task.isAchieved,
                      'points': task.points,
                    }).toList()
                  });

                  print('Task added successfully');

                  // Fetch the updated list of teams after adding the task
                  getTeams();

                  // Show a success message
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Task added successfully'),
                  ));

                  Navigator.pop(context);
                } else {
                  print("Invalid inputs. Task name: '$taskName', points: '$points'");
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }


  Stream<List<Team>> getTeams() async* {
    yield* db
        .collection('teams')
        .where('users', arrayContains: UserPage.userId)
        .snapshots()
        .asyncMap((snapshot) async {
      return await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data();
        final name = data['name'] as String?;
        final users = List<String>.from(data['users'] as List<dynamic>? ?? []);
        final tasks = (data['tasks'] as List<dynamic>? ?? []).map((taskData) {
          final taskMap = taskData as Map<String, dynamic>;
          final taskName = taskMap['name'] as String;
          final isAchieved = taskMap['isAchieved'] as bool;
          final points = taskMap['points'] as int;
          return Task(name: taskName, isAchieved: isAchieved, points: points);
        }).toList();

        if (name != null) {
          // Get the points for each user and sort
          final userPoints = await Future.wait(users.map((userId) async {
            return {userId: await getUserPoints(userId)};
          }));
          userPoints.sort((a, b) => b.values.first.compareTo(a.values.first));
          final sortedUsers = userPoints.map((e) => e.keys.first).toList();
          return Team(name: name, users: sortedUsers, tasks: tasks);
        }
        return null;
      }));
    }).map((teams) => teams.where((team) => team != null).cast<Team>().toList());
  }

  void joinTeam(String teamName) async {
    String teamId = teamName.replaceAll(' ', '');

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
    getTeams();
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
                  // Create a new team with the user
                  joinTeam(teamName);

                  // Fetch the updated list of teams after adding
                  getTeams();

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
          title: Text('Goals for ${team.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (team.tasks.isEmpty)
                const Text('No goals available')
              else
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: team.tasks.length,
                  itemBuilder: (context, index) {
                    final task = team.tasks[index];
                    return ListTile(
                      title: Text(
                        task.name,
                        // Use task.name instead of casting task to a string
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
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
      body: StreamBuilder<List<Team>>(
        stream: getTeams(),
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
                        icon: const Icon(Icons.add_box_outlined),
                        onPressed: () => addTaskToTeam(team),
                        tooltip: 'Add Team Goal',
                      ),
                      title: Text(
                        team.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      subtitle: Text('${team.memberCount} members'),
                      children: <Widget>[
                        StreamBuilder<List<Map<String, dynamic>>>(
                          stream: getUserData(team),
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                final usersWithPoints = snapshot.data!;
                                return Column(
                                  children: usersWithPoints
                                      .map((userData) => ListTile(
                                    leading: Text(
                                        '${usersWithPoints.indexOf(userData) + 1}',
                                        style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 17,
                                            color: Colors.deepPurple)),
                                    title: Text(userData['user'],
                                        style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text('${userData['points']} Points',
                                        style: const TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 16,
                                            color: Colors.black54)),
                                    tileColor: userData['user'] ==
                                        UserPage.userId
                                        ? Colors.deepPurple[50]
                                        : Colors.white,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UserGoalPage(
                                                userId: userData['user']),
                                      ),
                                    ),
                                  ))
                                      .toList(),
                                );
                              }
                            }
                          },
                        ),
                        const Divider(),
                        ...team.tasks.map((task) => ListTile(
                          title: Text(
                            task.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                '+${task.points} points  ',
                                style: TextStyle(color: task.isAchieved ? Colors.green : Colors.black54, fontFamily: 'Roboto', fontSize: 16),
                              ),
                              Checkbox(
                                value: task.isAchieved,
                                onChanged: (bool? value) {
                                  setState(() {
                                    task.isAchieved = value!;
                                  });

                                  // Get the updated tasks list
                                  List<Map<String, dynamic>> updatedTasks = team.tasks
                                      .map((t) => {
                                    'name': t.name,
                                    'isAchieved': t == task ? task.isAchieved : t.isAchieved,
                                    'points': t.points,
                                  })
                                      .toList();

                                  // Update the tasks in Firestore
                                  db.collection('teams').doc(team.name)
                                      .update({'tasks': updatedTasks});

                                  // Update the points
                                  if (value == true) {
                                    db.collection('users').doc(UserPage.userId).update({
                                      'points': FieldValue.increment(task.points),
                                    });
                                  } else {
                                    db.collection('users').doc(UserPage.userId).update({
                                      'points': FieldValue.increment(-task.points),
                                    });
                                  }
                                },
                              ),
                            ]),
                          tileColor: task.isAchieved ? Colors.green[100] : null,
                        )).toList(),
                      ],
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
        child: const Icon(Icons.group_add),
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()));
              break;
            case 1:
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const GoalPage()));
              break;
          }
        },
      ),
    );
  }
}
