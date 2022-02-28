import 'package:flutter/material.dart';

class SingleMessage extends StatelessWidget {
  final String message;
  final bool isMe;
  final String type;
  SingleMessage(
      {required this.message, required this.isMe, required this.type});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return type == "text"
        ? Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.all(16),
                  constraints: BoxConstraints(maxWidth: 200),
                  decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.orange,
                      borderRadius: BorderRadius.all(Radius.circular(24))),
                  child: Text(
                    message,
                    style: TextStyle(color: Colors.white),
                  )),
            ],
          )
        : Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ShowImage(imageUrl: message)));
                  },
                  child: Container(
                    height: size.height / 2.5,
                    width: size.width / 2,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(24))),
                    alignment: message != "" ? null : Alignment.center,
                    child: message != ""
                        ? Image.network(
                            message,
                            fit: BoxFit.cover,
                          )
                        : Center(
                          child: CircularProgressIndicator(),
                        ) ,
                  ),
                ),
              ),
            ],
          );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}