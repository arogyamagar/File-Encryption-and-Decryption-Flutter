import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/models/usermodel.dart';
import '../widgets/message_textfield.dart';
import '../widgets/singlemessage.dart';

class ChatScreen extends StatelessWidget {
  final UserModel currentUser;
  final String friendId;
  final String friendName;
  final String friendImage;
  final String firendStatus;

  ChatScreen({
    required this.currentUser,
    required this.friendId,
    required this.friendName,
    required this.friendImage,
    required this.firendStatus,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Color(0xffee122a),
          title: Row(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child: Image.network(
                    friendImage,
                    height: 35,
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      friendName,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                        child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(friendId)
                                .snapshots(),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.data != null) {
                                return Column(
                                  children: <Widget>[
                                    Text(snapshot.data['status'],
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.white)),
                                  ],
                                );
                              } else {
                                return Container();
                              }
                            })),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Column(children: [
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(10),
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .collection('messages')
                    .doc(friendId)
                    .collection('chats')
                    .orderBy("date", descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data.docs.length,
                        reverse: true,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          bool isMe = snapshot.data.docs[index]['senderId'] ==
                              currentUser.uid;
                          return SingleMessage(
                            message: (snapshot.data.docs[index]['message']),
                            isMe: isMe,
                            type: snapshot.data.docs[index]['type'],
                          );
                        });
                  }
                  return const Center(child: CircularProgressIndicator());
                }),
          )),
          MessageTextField(currentUser.uid, friendId)
        ]),
      ),
    );
  }
}
