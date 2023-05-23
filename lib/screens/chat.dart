import 'package:chat/screens/profile.dart';
import 'package:chat/widgets/chat_messages.dart';
import 'package:chat/widgets/new_messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  void setupPushNotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    // final token = await fcm.getToken();
    // print(token);
    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();
    setupPushNotification();
  }

  @override
  Widget build(BuildContext context) {
    Future<String> getUrl() async {
      final data = await FirebaseFirestore.instance
          .collection('user-data')
          .doc(userId)
          .get();
      final imageUrl = data.data()!['image-url'];
      return imageUrl;
    }

    return Scaffold(
        appBar: AppBar(
          leading: FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              return Padding(
                padding: const EdgeInsets.all(5.0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  )),
                  child: Hero(
                    tag: userId,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(snapshot.data!),
                    ),
                  ),
                ),
              );
            },
            future: getUrl(),
          ),
          title: const Text('ChatApp'),
          actions: [
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          ],
        ),
        body: const Column(
          children: [
            Expanded(child: ChatMessages()),
            NewMessages(),
          ],
        ));
  }
}
