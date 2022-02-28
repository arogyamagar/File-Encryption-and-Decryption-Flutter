import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/widgets/message_textfield.dart';
import 'package:chat_app/widgets/single_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {

  final UserModel currentUser;
  final String friendId;
  final String friendName;
  final String friendImage;
  final String friendStatus;

  ChatScreen({
    required this.currentUser,
    required this.friendId,
    required this.friendName,
    required this.friendImage,
    required this.friendStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(80),
              child: Image.network(friendImage, height:  35,)
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(width: 5,),
                  Text(friendName, style: TextStyle(fontSize: 20),),
                  SizedBox(height: 2,),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                    child:StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(friendId).snapshots(),
                      builder: (context, AsyncSnapshot snapshot){
                        if(snapshot.data != null){
                          return Container(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 35, 0),
                                  child: Text(snapshot.data['status'], style: TextStyle(fontSize: 12)),
                                )
                              ],
                            )
                          );
                        } else {
                          return Container();
                        }
                      }
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25)
              )
            ),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).collection('messages').doc(friendId).collection('chats').orderBy("date", descending: true).snapshots(),
              builder: (context, AsyncSnapshot snapshot){
                if(snapshot.hasData){
                  if(snapshot.data.docs.length < 1){
                    return Center(
                      child: Text("Say Hi", style: TextStyle(fontSize: 20),),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data.docs.length,
                    reverse: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context,index){
                      bool isMe = snapshot.data.docs[index]['senderId'] == currentUser.uid;
                      return SingleMessage(type: snapshot.data.docs[index]['type'], message: snapshot.data.docs[index]['message'], isMe: isMe);
                    }
                  );
                }
                return Center(
                  child: CircularProgressIndicator()
                );


              }
              ),
          )),
          MessageTextField(currentUser.uid, friendId)
        ]
        ),
    );
  }
}