import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({Key ? key}) : super(key:key);

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final goalController = TextEditingController();
  final pointController = TextEditingController();

  @override
  void dispose() {
    goalController.dispose();
    pointController.dispose();
    super.dispose();
  }
  void addGoal() async {
    String goal = goalController.text;
    String points = pointController.text;
    if (goal.isNotEmpty) {
      await db.collection('tasks').add({'task': goal, 'achieved': false, 'points': int.parse(points), 'userId': UserPage.userId});
      goalController.clear();
      pointController.clear();
      Navigator.pop(context); // Go back to the previous page after adding the goal
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Goal'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: goalController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter a goal',
                ),
              ),
              TextField(
                controller: pointController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter points',
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                  onPressed: addGoal,
                  child: const Text('Add'),
                  style: ElevatedButton.styleFrom(primary: Colors.deepPurple)
              ),
            ],
          ),
        ),
      ),
    );
  }
}