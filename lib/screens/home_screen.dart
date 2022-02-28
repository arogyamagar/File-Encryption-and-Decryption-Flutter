import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/screens/auth_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/screens/search_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ignore: must_be_immutable
class HomeScreen extends StatefulWidget{
  UserModel user;
  // ignore: use_key_in_widget_constructors
  HomeScreen(this.user);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver{
  User? user = FirebaseAuth.instance.currentUser;
  @override

  void initState(){
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    setStatus('Online');
  }

  void setStatus (String status) async{
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      "status":status,
    });
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    if(state == AppLifecycleState.resumed){
      setStatus("Online");
      //online
    }
    else{
      setStatus("Offline");
      //offline
    }
  }
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
      title: const Text('Home'),
      centerTitle: true,
      backgroundColor: Colors.teal,
      actions:[
        IconButton(onPressed: ()async{
          await GoogleSignIn().signOut();
          await FirebaseAuth.instance.signOut();
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> AuthScreen()), (route) => false);
        }, icon: const Icon(Icons.logout))
      ],
      ),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.search),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>SearchScreen(widget.user)));
                  },
      ),
      );
  }
}