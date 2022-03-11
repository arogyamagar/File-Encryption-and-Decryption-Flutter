import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:encryptor/encryptor.dart';

class MessageTextField extends StatefulWidget {
  String? currentId;
  String? friendId;

  MessageTextField(this.currentId, this.friendId);

  @override
  _MessageTextFieldState createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  final TextEditingController _controller = TextEditingController();
  File? imagefile;
  File? file;
  String? fname;
  String password = "WKFGH^&@fka2345&13232&";

  Future selectfile() async {
    PlatformFile? pfile;
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;
    final path = result.files.single.path!;
    setState(() {
      file = File(path);
      // _path = file!.path;
      // encrypt();
      pfile = result.files.first;
      fname = pfile?.name;
      //fname = '$fname' + '.aes';
    });
    uploadFile();
    print(fname);
  }

  Future uploadFile() async {
    int status = 1;
    if (file == null) return;
    var fileName = fname;
    final destination = 'files/$fname';
    //  final destination = 'files/$fileName';

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentId)
        .collection('messages')
        .doc(widget.friendId)
        .collection('chats')
        .doc(fileName)
        .set({
      "senderId": widget.currentId,
      "receiverId": widget.friendId,
      "message": "",
      "type": "file",
      "date": DateTime.now(),
      'fileurl': "",
      "status": ""
    });

    final ref = FirebaseStorage.instance.ref(destination);
//var uploadTask = await ref.putFile(file!).catchError((error) async {
    var uploadTask = await ref.putFile(file!).catchError((error) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentId)
          .collection('messages')
          .doc(widget.friendId)
          .collection('chats')
          .doc(fileName)
          .delete();
      status = 0;
    });
    if (status == 1) {
      String fileUrl = await uploadTask.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentId)
          .collection('messages')
          .doc(widget.friendId)
          .collection('chats')
          .doc(fileName)
          .update({
        "senderId": widget.currentId,
        "receiverId": widget.friendId,
        "message": (fname!),
        "type": "file",
        "date": DateTime.now(),
        "fileurl": fileUrl,
        "status": ""
      }).then((value) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.currentId)
            .collection('messages')
            .doc(widget.friendId)
            .set({
          'last_msg': fname,
        });
      });
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.friendId)
          .collection('messages')
          .doc(widget.currentId)
          .collection('chats')
          .add({
        "senderId": widget.currentId,
        "receiverId": widget.friendId,
        "message": (fname!),
        "type": "file",
        "date": DateTime.now(),
        "fileurl": fileUrl,
        "status": ""
      }).then((value) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.friendId)
            .collection('messages')
            .doc(widget.currentId)
            .set({
          'last_msg': (fname!),
        });
      });

      print(fileUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.white,
      padding: const EdgeInsets.fromLTRB(5, 1, 5, 55),
      child: Row(children: [
        Expanded(
            child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {
                selectfile();
              },
              icon: const Icon(Icons.file_present_sharp),
              color: Colors.white,
            ),
            labelText: "Enter Message",
            floatingLabelAlignment: FloatingLabelAlignment.start,
            floatingLabelStyle: TextStyle(
              fontSize: 20,
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(width: 0),
              gapPadding: 10,
              borderRadius: BorderRadius.circular(25),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffee122a), width: 1.5),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        )),
        const SizedBox(
          width: 20,
        ),
        GestureDetector(
          onTap: () async {
            FocusScope.of(context).unfocus();
            String message = _controller.text;

            if (_controller.text.isNotEmpty) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.currentId)
                  .collection('messages')
                  .doc(widget.friendId)
                  .collection('chats')
                  .add({
                "senderId": widget.currentId,
                "receiverId": widget.friendId,
                "message": Encryptor.encrypt(password, message),
                "type": "text",
                "date": DateTime.now(),
                "status": ""
              }).then((value) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.currentId)
                    .collection('messages')
                    .doc(widget.friendId)
                    .set({
                  'last_msg': Encryptor.encrypt(password, message),
                });
              });

              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(widget.friendId)
                  .collection('messages')
                  .doc(widget.currentId)
                  .collection('chats')
                  .add({
                "senderId": widget.currentId,
                "receiverId": widget.friendId,
                "message": Encryptor.encrypt(password, message),
                "type": "text",
                "date": DateTime.now(),
                "status": ""
              }).then((value) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.friendId)
                    .collection('messages')
                    .doc(widget.currentId)
                    .set({
                  'last_msg': Encryptor.encrypt(password, message),
                });
              });
              _controller.clear();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter message')));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xffee122a),
            ),
            child: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        )
      ]),
    );
  }
}
