import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? email;
  String? name;
  String? image;
  Timestamp? date;
  String? uid;
  String? status;

  UserModel({
    required this.email,
    required this.name,
    required this.image,
    required this.date,
    required this.uid,
    required this.status,
  });

  factory UserModel.fromJson(DocumentSnapshot snapshot) {
    return UserModel(
        email: snapshot['email'],
        name: snapshot['name'],
        image: snapshot['image'],
        date: snapshot['date'],
        uid: snapshot['uid'],
        status: snapshot['status']);
  }
}
