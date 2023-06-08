import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main.dart';

class WeeklyRecapPage extends StatefulWidget {

  const WeeklyRecapPage({Key?key}): super(key:key);

  @override
  State<WeeklyRecapPage> createState() => _WeeklyRecapPage();
}

class _WeeklyRecapPage extends State<WeeklyRecapPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  late ConfettiController controller;

  @override
  void initState() {
    super.initState();
    controller = ConfettiController(duration: Duration(seconds: 10));
    controller.play();
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
        title: const Text('Congratulations!'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "That's a wrap!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            FutureBuilder<int>(
              future: getUserCompleted(UserPage.userId),
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final completedGoals = snapshot.data;
                    return FutureBuilder<int>(
                      future: getUserPoints(UserPage.userId),
                      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final totalPoints = snapshot.data;
                            return Text(
                              'Congrats! This week you have achieved $completedGoals goals, for a total of $totalPoints points.',
                              style: const TextStyle(fontSize: 18),
                            );
                          }
                        }
                      },
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 32),
            // ConfettiWidget(
            //   confettiController: controller,
            //   blastDirectionality: BlastDirectionality.explosive,
            //   shouldLoop: true,
            //   colors: const [
            //     Colors.green,
            //     Colors.blue,
            //     Colors.orange,
            //     Colors.purple,
            //     Colors.yellow,
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
