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
  int selectedIndex = 0; // Default selected index is 0 (Work)

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
        'points': int.parse(points),
        'type': selectedIndex == 0 ? 'Work' : 'Life', // Add the task type to the Firestore document
        'userId': UserPage.userId,
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
              const SizedBox(height: 16.0),
              Container(
                width: double.infinity,
                height: 50.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(
                    color: Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 0; // Set the selected index to 0 (Work)
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(28.0),
                              bottomLeft: Radius.circular(28.0),
                            ),
                            color: selectedIndex == 0 ? Colors.deepPurple : Colors.grey,
                          ),
                          child: Text(
                            'Work',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: selectedIndex == 0 ? Colors.white : Colors.black,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = 1; // Set the selected index to 1 (Life)
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(28.0),
                              bottomRight: Radius.circular(28.0),
                            ),
                            color: selectedIndex == 1 ? Colors.deepPurple : Colors.grey,
                          ),
                          child: Text(
                            'Life',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              color: selectedIndex == 1 ? Colors.white : Colors.black,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: addGoal,
                style: ElevatedButton.styleFrom(
                  primary: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('Add', style: TextStyle(fontFamily: 'Roboto', fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
