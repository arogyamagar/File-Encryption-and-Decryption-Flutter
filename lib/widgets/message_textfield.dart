import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';


class MessageTextField extends StatefulWidget {
  String? currentId;
  String friendId;

  MessageTextField(this.currentId, this.friendId);

  @override
  _MessageTextFieldState createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  TextEditingController _controller = TextEditingController();
  File? imageFile;
  Future getImage() async{
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile){
      if(xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async{

    String fileName = Uuid().v1();
    int status = 1;

    await FirebaseFirestore.instance.collection('users').doc(widget.currentId).collection('messages').doc(widget.friendId).collection('chats').doc(fileName).set({
      "senderId": widget.currentId,
      "receiverId": widget.friendId,
      "message": "",
      "type": "img",
      "date": DateTime.now(),
      "status": "",
    });
    
    var ref = FirebaseStorage.instance.ref().child('image').child("$fileName.jpg");
    var uploadTask = await ref.putFile(imageFile!).catchError((error) async{
      await FirebaseFirestore.instance.collection('users').doc(widget.currentId).collection('messages').doc(widget.friendId).collection('chats').doc(fileName).delete();
      status = 0;
    });

    if(status == 1){
      String ImageUrl = await uploadTask.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(widget.currentId).collection('messages').doc(widget.friendId).collection('chats').doc(fileName).update({
        "senderId": widget.currentId,
        "receiverId": widget.friendId,
        "message": ImageUrl,
        "type":"img",
        "date": DateTime.now(),
        "status": "",
      }).then((value){
      FirebaseFirestore.instance.collection('users').doc(widget.currentId).collection('messages').doc(widget.friendId).set({
        'last_msg':ImageUrl,
      });
      });  

      await FirebaseFirestore.instance.collection("users").doc(widget.friendId).collection('messages').doc(widget.currentId).collection('chats').add({
        "senderId": widget.currentId,
        "receiverId": widget.friendId,
        "message": ImageUrl,
        "type":"img",
        "date": DateTime.now(),
        "status": "",
      }).then((value){
        FirebaseFirestore.instance.collection('users').doc(widget.friendId).collection('messages').doc(widget.currentId).set({
          'last_msg':ImageUrl,
        });
      });

    }}
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsetsDirectional.all(8),
      child: Row(children: [
        Expanded(child: TextField(
          controller: _controller,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                  onPressed: () => getImage(),
                icon: Icon(Icons.file_present_sharp)
              ),
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
            if(_controller.text.isNotEmpty){
            _controller.clear();
            await FirebaseFirestore.instance.collection('users').doc(widget.currentId).collection('messages').doc(widget.friendId).collection('chats').add({
              "senderId": widget.currentId,
              "receiverId": widget.friendId,
              "message": message,
              "type":"text",
              "date": DateTime.now(),
              "status": "",
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
              "status": "",
            }).then((value){
              FirebaseFirestore.instance.collection('users').doc(widget.friendId).collection('messages').doc(widget.currentId).set({
                'last_msg':message,
              });
            });
            }
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
