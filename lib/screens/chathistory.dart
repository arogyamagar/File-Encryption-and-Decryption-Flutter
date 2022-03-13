import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/models/usermodel.dart';
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
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.user.uid)
              .collection('messages')
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.docs.length < 1) {
                return Center(
                  child: Text("No Chats Available !"),
                );
              }
              return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    var friendId = snapshot.data.docs[index].id;
                    // var email = snapshot.data.docs[email];
                    return FutureBuilder(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(friendId)
                          .get(),
                      builder: (context, AsyncSnapshot asyncSnapshot) {
                        if (asyncSnapshot.hasData) {
                          var friend = asyncSnapshot.data;
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(80),
                              child: CachedNetworkImage(
                                imageUrl: friend['image'],
                                placeholder: (conteext, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                ),
                                height: 50,
                              ),
                            ),
                            title: Text(friend['name']),
                            subtitle: Container(
                              child: Text(
                                friend['email'],
                                style: TextStyle(color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                            currentUser: widget.user,
                                            friendId: friend['uid'],
                                            friendName: friend['name'],
                                            friendImage: friend['image'],
                                            firendStatus: '',
                                          )));
                            },
                          );
                        }
                        return LinearProgressIndicator();
                      },
                    );
                  });
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
