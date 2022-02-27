import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessageTextField extends StatefulWidget {
  String? currentId;
  String friendId;

  MessageTextField(this.currentId, this.friendId);

  @override
  _MessageTextFieldState createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsetsDirectional.all(8),
      child: Row(children: [
        Expanded(child: TextField(
          controller: _controller,
            decoration: InputDecoration(
              labelText: "Type Your Message",
              fillColor: Colors.grey[100],
              filled:true,
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 0),
                gapPadding: 10,
                borderRadius: BorderRadius.circular(25)
              )
            ),
        )),
        SizedBox(width: 20,),
        GestureDetector(
          onTap: ()async{
            String message = _controller.text;
            _controller.clear();
            await FirebaseFirestore.instance.collection('users').doc(widget.currentId).collection('messages').doc(widget.friendId).collection('chats').add({
              "senderId": widget.currentId,
              "receiverId": widget.friendId,
              "message": message,
              "type":"text",
              "date": DateTime.now(),
            }).then((value){
              FirebaseFirestore.instance.collection('users').doc(widget.currentId).collection('messages').doc(widget.friendId).set({
                'last_msg':message,
              });
            });

            await FirebaseFirestore.instance.collection("users").doc(widget.friendId).collection('messages').doc(widget.currentId).collection('chats').add({
              "senderId":widget.currentId,
              "receiverId":widget.friendId,
              "message":message,
              "type":"text",
              "date":DateTime.now(),
            }).then((value){
              FirebaseFirestore.instance.collection('users').doc(widget.friendId).collection('messages').doc(widget.currentId).set({
                'last_msg':message,
              });
            });
          },
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            child: Icon(Icons.send, color: Colors.white,),
          ),
        )
      ]),
    );
  }
}