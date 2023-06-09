import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'addGoal.dart';
import 'main.dart';
import 'teams.dart';

class GoalPage extends StatefulWidget {

  const GoalPage({Key ? key}) : super(key:key);

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  static FirebaseFirestore db = FirebaseFirestore.instance;
  late int userPoints = 0;

  @override
  void initState() {
    super.initState();
    loadUserPoints();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadUserPoints() async {
    int points = await getUserPoints(UserPage.userId);
    setState(() {
      userPoints = points;
    });
  }

  Future<int> getUserPoints(String userId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userRef.get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      final points = data['points'];
      return points;
    } else {
      return 0;
    }
  }

  Future<bool> getIsPrivate(String taskId) async {
    final taskRef = FirebaseFirestore.instance.collection('tasks').doc(taskId);
    final snapshot = await taskRef.get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      final isPrivate = data['isPrivate'] ?? false; // If isPrivate is null, it's set to false
      return isPrivate;
    } else {
      return false; // Default value if the document doesn't exist
    }
  }

  void toggleAchieved(String taskId, String userId, bool currentStatus, int points) async {
    await db.collection('tasks').doc(taskId).update({'achieved': !currentStatus});
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userRef.get();
    final data = snapshot.data() as Map<String, dynamic>;
    int totalPoints = data['points'];
    int completed = data['completed'];
    if (!currentStatus) {
      totalPoints += points;
      completed += 1;
    } else {
      totalPoints -= points;
      completed = (completed > 0) ? completed - 1 : 0;
    }
    await userRef.update({'points': totalPoints, 'completed': completed});

    // update the userPoints state and refresh the UI
    setState(() {
      userPoints = totalPoints;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Goals',
          style: TextStyle(fontFamily: 'Roboto', fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 60),
            Text(
              "$userPoints AscentPoints ✨",
              style: TextStyle(
                  fontSize: 26,
                  color: Colors.green[500],
                  fontFamily: 'Roboto'),
            ),
            const SizedBox(height: 32),
            FloatingActionButton(
              heroTag: "btn1",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddGoalPage()),
                );
              },
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add, color: Colors.white),
            ),
            const SizedBox(height: 32),
            Flexible(
              child: StreamBuilder<QuerySnapshot>(
                stream: db.collection('tasks').where('userId', isEqualTo: UserPage.userId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                  }
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final task = documents[index];
                      final taskId = task.id;
                      final data = task.data() as Map<String, dynamic>;
                      final isAchieved = data['achieved'] ?? false;
                      final points = data['points'] ?? 0;
                      final userId = data['userId'];
                      return Card(
                        color: isAchieved ? Colors.green[100] : Colors.white,
                        child: ListTile(
                          title: Text(data['task'] ?? 'Default task', style: const TextStyle(fontFamily: 'Roboto', fontSize: 16)),
                          leading: Icon(
                            data['isPrivate'] ?? false ? Icons.lock : Icons.lock_open, // Show different icons based on 'isPrivate'
                            color: data['isPrivate'] ?? false ? Colors.red : Colors.green,
                          ),
                          trailing: TextButton(
                            onPressed: () => toggleAchieved(taskId, userId, isAchieved, points),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const SizedBox(width: 10),
                                Text(
                                  '+$points points  ',
                                  style: TextStyle(color: isAchieved ? Colors.green : Colors.black54, fontFamily: 'Roboto', fontSize: 16),
                                ),
                                Icon(
                                  isAchieved ? Icons.check_box : Icons.check_box_outline_blank,
                                  color: isAchieved ? Colors.green : Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 32)
          ],
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
        currentIndex: 1,
        selectedItemColor: Colors.deepPurple,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const MyHomePage()));
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
    );
  }
}
