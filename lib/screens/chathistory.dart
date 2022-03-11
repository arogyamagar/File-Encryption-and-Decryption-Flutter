import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chatscreen.dart';

class ChatHistory extends StatefulWidget {
  UserModel user;
  ChatHistory({
    required this.user,
  });

  @override
  State<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(3, 30, 3, 0),
      child: Center(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .orderBy('date')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (snapshot.data!.docs[index]['uid'] !=
                        FirebaseAuth.instance.currentUser!.uid) {
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(80),
                          child: Image.network(
                            snapshot.data!.docs[index]['image'],
                            height: 45,
                          ),
                        ),
                        title: Text(snapshot.data!.docs[index]['name']),
                        subtitle: Text(snapshot.data!.docs[index]['email']),
                        trailing: IconButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                            currentUser: widget.user,
                                            friendId: snapshot.data!.docs[index]
                                                ['uid'],
                                            friendName: snapshot
                                                .data!.docs[index]['name'],
                                            friendImage: snapshot
                                                .data!.docs[index]['image'],
                                            firendStatus: snapshot
                                                .data!.docs[index]['status'],
                                          )));
                            },
                            icon: const Icon(Icons.message)),
                      );
                    } else {
                      return const Text(" ");
                    }
                  });
            }),
      ),
    );
  }
}
