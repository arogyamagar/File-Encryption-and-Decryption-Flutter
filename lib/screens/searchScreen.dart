import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/models/usermodel.dart';
import 'package:flutter/material.dart';

import 'chatscreen.dart';

class SearchScreen extends StatefulWidget {
  UserModel user;
  // ignore: use_key_in_widget_constructors
  SearchScreen(this.user);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map> searchResult = [];
  bool isLoading = false;

  void onSearch() async {
    setState(() {
      searchResult = [];
      isLoading = true;
    });
    await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: searchController.text)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("No User Found")));
        setState(() {
          isLoading = false;
        });
        return;
      }
      value.docs.forEach((user) {
        if (user.data()['email'] != widget.user.email) {
          searchResult.add(user.data());
        }
      });
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
      child: Scaffold(
        appBar: AppBar(
          // ignore: prefer_const_constructors
          title: Text("Search your Friend"),
          backgroundColor: Color(0xffee122a),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                          hintText: "Type Email...",
                          
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      onSearch();
                      // ignore: prefer_const_constructors
                    },
                    icon: const Icon(Icons.search))
              ],
            ),
            if (searchResult.length > 0)
              Expanded(
                  child: ListView.builder(
                      itemCount: searchResult.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            child: Image.network(searchResult[index]['image']),
                          ),
                          title: Text(searchResult[index]['name']),
                          subtitle: Text(searchResult[index]['email']),
                          trailing: IconButton(
                              onPressed: () {
                                setState(() {
                                  searchController.text = "";
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                              currentUser: widget.user,
                                              friendId: searchResult[index]
                                                  ['uid'],
                                              friendName: searchResult[index]
                                                  ['name'],
                                              friendImage: searchResult[index]
                                                  ['image'],
                                              firendStatus: searchResult[index]
                                                  ['status'],
                                            )));
                              },
                              icon: const Icon(Icons.message)),
                        );
                      }))
            else if (isLoading == true)
              const Center(
                child: CircularProgressIndicator(),
              )
          ],
        ),
      ),
    );
  }
}
