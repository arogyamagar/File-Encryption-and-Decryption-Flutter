import 'package:encryptor/encryptor.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class SingleMessage extends StatelessWidget {
  final String message;
  final bool isMe;
  final String type;
  SingleMessage({
    required this.message,
    required this.isMe,
    required this.type,
  });
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  String password = "WKFGH^&@fka2345&13232&";

  @override
  Widget build(BuildContext context) {
    if (type == "text") {
      return Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          GestureDetector(
            onDoubleTap: () {},
            child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxWidth: 200),
                decoration: BoxDecoration(
                    color: isMe
                        ? const Color(0xffee122a)
                        : const Color(0xff282828),
                    borderRadius: const BorderRadius.all(Radius.circular(30))),
                child: Text(
                  Encryptor.decrypt(password, message),
                  style: const TextStyle(
                    color: Color(0xFFF5FCF9),
                  ),
                )),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: InkWell(
              onTap: () async {
                Dio dio = Dio();
                int success = 0;
                // String message1 = '$message' + '.aes';
                // print(message1);
                String downloadURL =
                    await storage.ref('files/$message').getDownloadURL();
                final dir = await getExternalStorageDirectory();
                final localpath = "${dir!.path}/$message";

                await dio
                    .download(downloadURL, localpath, deleteOnError: true)
                    .then((_) {
                  success = 1;
                });
                print(localpath);

                if (success == 1) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: const Color.fromARGB(255, 3, 128, 7),
                      content: Text(
                        'downloaded file on location :$localpath',
                      )));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text('download failed! please try again')));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxWidth: 200),
                decoration: BoxDecoration(
                    color: isMe
                        ? const Color(0xffee122a)
                        : const Color(0xFF282828),
                    borderRadius: const BorderRadius.all(Radius.circular(24))),
                alignment: message != "" ? null : Alignment.center,
                child: message != ""
                    ? Text(
                        message,
                        style: const TextStyle(
                            color: Color(0xFFF5FCF9),
                            decoration: TextDecoration.underline),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      );
    }
  }
}
