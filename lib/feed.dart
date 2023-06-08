import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Feed extends StatefulWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  CollectionReference tasksCollection = FirebaseFirestore.instance.collection('tasks');
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      QuerySnapshot querySnapshot = await tasksCollection.get();
      List<Task> fetchedTasks = [];
      for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        fetchedTasks.add(Task.fromSnapshot(documentSnapshot));
      }
      setState(() {
        tasks = fetchedTasks;
      });
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feed'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(tasks[index].title),
            subtitle: Text(tasks[index].description),
          );
        },
      ),
    );
  }
}


class Task {
  final String title;
  final String description;

  Task({
    required this.title,
    required this.description,
  });

  factory Task.fromSnapshot(QueryDocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Task(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
    );
  }
}

