import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({Key? key}) : super(key: key);

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final goalController = TextEditingController();

  @override
  void dispose() {
    goalController.dispose();
    super.dispose();
  }
  void addGoal() async {
    String goal = goalController.text;
    if (goal.isNotEmpty) {
      await db.collection('tasks').add({'task': goal, 'achieved': false, 'points': 10});
      goalController.clear();
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
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: addGoal,
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}