import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserGoalPage extends StatefulWidget {

  const UserGoalPage({Key? key, required this.userId}):super(key:key);

  final String userId;

  @override
  State<UserGoalPage> createState() => _UserGoalPageState();
}

class _UserGoalPageState extends State<UserGoalPage> {
  static FirebaseFirestore db = FirebaseFirestore.instance;

  late int userPoints = 0;
  late String userId = widget.userId;

  @override
  void initState() {
    super.initState();
    userId = widget.userId;
    loadUserPoints();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void loadUserPoints() async {
    int points = await getUserPoints(userId);
    setState(() {
      userPoints = points;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "$userId's Goals",
          style: const TextStyle(fontFamily: 'Roboto', fontSize: 24, color: Colors.white),
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
            Flexible(
              child: StreamBuilder<QuerySnapshot>(
                stream: db.collection('tasks').where('userId', isEqualTo: userId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Colors.deepPurple));
                  }
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  // Filter out tasks that are marked as private
                  final List<DocumentSnapshot> publicTasks = documents.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['isPrivate'] == null || !data['isPrivate'];
                  }).toList();
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: publicTasks.length,
                    itemBuilder: (context, index) {
                      final task = publicTasks[index];
                      final data = task.data() as Map<String, dynamic>;
                      final isAchieved = data['achieved'] ?? false;
                      final points = data['points'] ?? 0;
                      return Card(
                        color: isAchieved ? Colors.green[100] : Colors.white,
                        child: ListTile(
                          title: Text(data['task'] ?? 'Default task', style: const TextStyle(fontFamily: 'Roboto', fontSize: 16)),
                          trailing: Text(
                            '$points points  ',
                            style: TextStyle(color: isAchieved ? Colors.green : Colors.black54, fontFamily: 'Roboto', fontSize: 16),
                          ),

                        ),
                      );
                    },
                  );
                },
              )
            ),
            const SizedBox(height: 32)
          ],
        ),
      ),
    );
  }
}
