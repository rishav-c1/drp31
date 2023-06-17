import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({Key? key}) : super(key: key);

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final goalController = TextEditingController();
  final pointController = TextEditingController();
  bool isPrivate = false;

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
      await db.collection('tasks').add({
        'task': goal,
        'achieved': false,
        'points': int.parse(points), // Add the task type to the Firestore document
        'userId': UserPage.userId,
        'isPrivate': isPrivate, // Add the task privacy status to the Firestore document
      });
      goalController.clear();
      pointController.clear();
      Navigator.pop(context); // Go back to the previous page after adding the goal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Goal', style: TextStyle(fontFamily: 'Roboto', fontSize: 24, color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
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
                  hintStyle: TextStyle(fontFamily: 'Roboto'),
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                controller: pointController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter points',
                  hintStyle: TextStyle(fontFamily: 'Roboto'),
                ),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                title: const Text('Private', style: TextStyle(fontFamily: 'Roboto')),
                value: isPrivate,
                onChanged: (bool value) {
                  setState(() {
                    isPrivate = value;
                  });
                },
                secondary: const Icon(Icons.lock),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: 70, // Adjust the width to your desired size
                height: 70,
                child: ElevatedButton(
                  onPressed: addGoal,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35), // Half of width/height for a circle button
                      ),
                    ),
                    padding: MaterialStateProperty.all(const EdgeInsets.all(0)), // Remove padding
                    elevation: MaterialStateProperty.all(0), // Remove elevation/shadow
                  ),
                  child: Icon(Icons.add, size: 32, color: Colors.white), // Plus icon
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
