import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'homescreen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ignore: non_constant_identifier_names
  Future SignInFunction() async {
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return;
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    DocumentSnapshot userExist =
        await firestore.collection('users').doc(userCredential.user!.uid).get();

    if (userExist.exists) {
      // ignore: avoid_print
      print("User Already Exists in Database");
    } else {
      await firestore.collection("users").doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'name': userCredential.user!.displayName,
        'image': userCredential.user!.photoURL,
        'uid': userCredential.user!.uid,
        'date': DateTime.now(),
        'status': "",
      });
    }

    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => Login()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 20,
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(10, 100, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Image(
                      image: AssetImage(
                        "assets/images/ic_launcher.png",
                      ),
                      height: 200,
                    )
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: ElevatedButton(
                  onPressed: () async {
                    await SignInFunction();
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/1024px-Google_%22G%22_Logo.svg.png',
                        height: 25,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        "LogIn With Google",
                        style: TextStyle(fontSize: 20),
                      )
                    ],
                  ),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 139, 5, 5),
                      ),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 12))),
                ),
              )
            ],
          ),
        ),
      ),
    )));
  }
}

class Login extends StatelessWidget {
  // This widget is the root of your application.

  Future<Widget> userSignedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      UserModel userModel = UserModel.fromJson(userData);
      return HomeScreen(userModel);
    } else {
      return AuthScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: userSignedIn(),
        builder: (context, AsyncSnapshot<Widget> snapshot) {
          if (snapshot.hasData) {
            return snapshot.data!;
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}
