import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'main.dart';

class JoinTeamPage extends StatefulWidget {
  const JoinTeamPage({Key? key}) : super(key: key);

  @override
  State<JoinTeamPage> createState() => _JoinTeamPage();
}

class _JoinTeamPage extends State<JoinTeamPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final idController = TextEditingController();
  final nameController = TextEditingController();

  @override
  void dispose() {
    idController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void addTeam(String id, String name) async {
    if (id.isNotEmpty) {
      final teamRef = db.collection('teams');
      final teamDoc = teamRef.doc(id);
      final teamSnapshot = await teamDoc.get();
      if (teamSnapshot.exists) {
        await teamDoc.update({
          'users': FieldValue.arrayUnion([UserPage.userId]),
        });
      } else {
        final newTeam = {
          'name': name,
          'users': [UserPage.userId],
        };
        await teamDoc.set(newTeam);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Team'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: idController,
              decoration: InputDecoration(
                labelText: 'Enter Team ID',
              ),
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Enter Team Name',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final id = idController.text;
                final name = nameController.text;
                addTeam(id, name);
                idController.clear();
                nameController.clear();
                Navigator.pop(context);
              },
              child: Text('Join Team'),
              style: ElevatedButton.styleFrom(primary: Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }
}