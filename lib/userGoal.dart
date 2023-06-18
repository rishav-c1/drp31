import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserGoalPage extends StatefulWidget {
  const UserGoalPage({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  State<UserGoalPage> createState() => _UserGoalPageState();
}

class _UserGoalPageState extends State<UserGoalPage> {
  static FirebaseFirestore db = FirebaseFirestore.instance;

  late Stream<int> userPointsStream;

  @override
  void initState() {
    super.initState();
    userPointsStream = getUserPoints(widget.userId);
  }

  Stream<int> getUserPoints(String userId) {
    final userRef = db.collection('users').doc(userId);
    return userRef.snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final points = data['points'] ?? 0;
        return points;
      } else {
        return 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.userId}'s Goals",
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
            StreamBuilder<int>(
              stream: userPointsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  final points = snapshot.data ?? 0;
                  return Text(
                    "$points AscentPoints ✨",
                    style: TextStyle(
                        fontSize: 26,
                        color: Colors.green[500],
                        fontFamily: 'Roboto'),
                  );
                }
              },
            ),
            const SizedBox(height: 32),
            Flexible(
              child: StreamBuilder<QuerySnapshot>(
                stream: db.collection('tasks').where('userId', isEqualTo: widget.userId).snapshots(),
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
