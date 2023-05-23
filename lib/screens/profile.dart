import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    Future<dynamic> getUserData() async {
      final data = await FirebaseFirestore.instance
          .collection('user-data')
          .doc(userId)
          .get();
      final userData = data.data();
      return userData;
    }

    Future<void> updateData(String newData, String newField) async {
      await FirebaseFirestore.instance
          .collection('user-data')
          .doc(userId)
          .update({newField: newData});
    }

    final usernameField = TextEditingController();
    final aboutField = TextEditingController();
    final phoneField = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('About You'),
      ),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          aboutField.text = snapshot.data['about'];
          usernameField.text = snapshot.data['username'];
          phoneField.text = snapshot.data['phone'];
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Hero(
                      tag: userId,
                      child: CircleAvatar(
                        radius: 100,
                        backgroundImage: NetworkImage(
                          snapshot.data['image-url'],
                        ),
                      ),
                    ),
                  ),
                  TextField(
                    controller: usernameField,
                    decoration: const InputDecoration(
                        labelText: 'Username', icon: Icon(Icons.person)),
                    onEditingComplete: () {
                      updateData(usernameField.text, 'username');
                    },
                  ),
                  TextField(
                    controller: aboutField,
                    decoration: const InputDecoration(
                        labelText: 'About', icon: Icon(Icons.info)),
                    onEditingComplete: () {
                      updateData(aboutField.text, 'about');
                    },
                  ),
                  TextField(
                    controller: phoneField,
                    decoration: const InputDecoration(
                        labelText: 'Phone', icon: Icon(Icons.call)),
                    onEditingComplete: () {
                      updateData(phoneField.text, 'phone');
                    },
                  )
                ],
              ),
            ),
          );
        },
        future: getUserData(),
      ),
    );
  }
}
