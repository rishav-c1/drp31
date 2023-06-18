import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main.dart';

class WeeklyRecapPage extends StatefulWidget {

  const WeeklyRecapPage({Key?key}): super(key:key);

  @override
  State<WeeklyRecapPage> createState() => _WeeklyRecapPage();
}

class _WeeklyRecapPage extends State<WeeklyRecapPage> with SingleTickerProviderStateMixin {
  static FirebaseFirestore db = FirebaseFirestore.instance;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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

  Future<int> getUserCompleted(String userId) async {
    final userRef = db.collection('users').doc(userId);
    final snapshot = await userRef.get();

    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      final completed = data['completed'];
      return completed;
    } else {
      return 0;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Congratulations!', style: TextStyle(fontFamily: 'Roboto', fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                "That's a wrap!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Roboto', color: Colors.deepPurple),
              ),
              const SizedBox(height: 32),
              FutureBuilder<int>(
                future: getUserCompleted(UserPage.userId),
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.deepPurple,
                      ),
                    );
                  } else {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}', style: const TextStyle(fontSize: 18, fontFamily: 'Roboto', color: Colors.red));
                    } else {
                      final completedGoals = snapshot.data;
                      return FutureBuilder<int>(
                        future: getUserPoints(UserPage.userId),
                        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.deepPurple,
                              ),
                            );
                          } else {
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}', style: const TextStyle(fontSize: 18, fontFamily: 'Roboto', color: Colors.red));
                            } else {
                              final totalPoints = snapshot.data;
                              return Text(
                                'Congratulations! This week you have achieved $completedGoals goals, for a total of $totalPoints points.',
                                style: TextStyle(fontSize: 18, fontFamily: 'Roboto', color: Colors.deepPurple[700]),
                                textAlign: TextAlign.center,
                              );
                            }
                          }
                        },
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 32),
              AnimatedIcon(
                icon: AnimatedIcons.event_add,
                progress: controller,
                size: 100,
                color: Colors.deepPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
