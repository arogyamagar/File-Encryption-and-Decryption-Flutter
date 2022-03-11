import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/screens/chathistory.dart';
import 'package:chat_app/screens/profilescreen.dart';
import 'package:chat_app/screens/searchScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/usermodel.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  UserModel user;
  // ignore: use_key_in_widget_constructors
  HomeScreen(this.user);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  User? user1 = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    setStatus('Online');
    requestPermission();
  }

  void setStatus(String status) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user1!.uid)
        .update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setStatus("Online");

      //online
    }

    //offline
    else {
      setStatus("Offline");
    }
  }

  void requestPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    var status1 = await Permission.manageExternalStorage.status;
    if (!status1.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Users',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.height / 25,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: userNavigator(
        user: widget.user,
      ),
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        backgroundColor: Color(0xffee122a),
        actions: [
          IconButton(
              onPressed: () async {
                await GoogleSignIn().signOut();
                await FirebaseAuth.instance.signOut();
                // Navigator.pushNamed(context, '/login');
                setStatus('Offline');
                Navigator.push(
                    context,
                    PageRouteBuilder(
                        transitionDuration: Duration(seconds: 0),
                        transitionsBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secAnimation,
                            Widget child) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                            alignment: Alignment.center,
                          );
                        },
                        pageBuilder: (BuildContext context,
                            Animation<double> animation,
                            Animation<double> secAnimation) {
                          return AuthScreen();
                        }));
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: ChatHistory(user: widget.user),
    );
  }
}

class userNavigator extends StatefulWidget {
  UserModel user;
  userNavigator({
    required this.user,
  });

  @override
  State<userNavigator> createState() => _userNavigatorState();
}

class _userNavigatorState extends State<userNavigator> {
  final padding = const EdgeInsets.symmetric(horizontal: 30);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Material(
        color: Color(0xFF282828),
        child: ListView(
          padding: padding,
          children: <Widget>[
            const SizedBox(
              height: 48,
            ),
            Column(
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 45, 0, 0),
                    child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.user.uid)
                            .snapshots(),
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.data != null) {
                            return Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(80),
                                      child: Image.network(
                                        snapshot.data['image'],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 25, 0, 0),
                                  child: Text(snapshot.data['name'],
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 24)),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 25, 0, 0),
                                  child: Text(snapshot.data['email'],
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 15)),
                                ),
                              ],
                            );
                          } else {
                            return const CircularProgressIndicator();
                          }
                        })),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            const Divider(color: Colors.white30, thickness: 1),
            buildMenuItem(
                text: 'Search',
                icon: Icons.search,
                onClicked: () => selectedItem(context, 0)),
            const SizedBox(
              height: 8,
            ),
            const Divider(color: Colors.white30, thickness: 1),
            buildMenuItem(
              text: 'Profile',
              icon: Icons.person_outline_rounded,
              onClicked: () => selectedItem(context, 1),
            ),
            const SizedBox(
              height: 1,
            ),
            const Divider(color: Colors.white30, thickness: 1),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    VoidCallback? onClicked,
  }) {
    const color = Colors.white;
    const hoverColor = Colors.white70;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        text,
        style: const TextStyle(color: color),
      ),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();
    switch (index) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SearchScreen(widget.user)));
        break;
      case 1:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => profilescreen(widget.user)));
        break;
    }
  }
}
