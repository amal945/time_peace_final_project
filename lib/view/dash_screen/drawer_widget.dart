import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:time_peace_project/view/about_us/about_us.dart';
import 'package:time_peace_project/view/dash_screen/alert.dart';
import 'package:time_peace_project/view/privacy_policy/privacy_policy.dart';
import 'package:time_peace_project/view/terms_and_conditons/terms_and_conditons.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  late Future<String> _userNameFuture;

  @override
  void initState() {
    super.initState();
    _userNameFuture = fetchUserName();
  }

  Future<String> fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email!;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        return userDoc['username'];
      }
    }
    return ''; // Return empty string if username is not found
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[200],
        child: FutureBuilder<String>(
          future: _userNameFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              String userName = snapshot.data ?? 'Loading...';
              return ListView(
                children: [
                  DrawerHeader(
                    child: Center(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 45,
                            backgroundImage: AssetImage("assets/cartpng.png"),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Montserrat",
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PrivacyPolicyPage()));
                    },
                    child: const ListTile(
                      leading: Icon(
                        Icons.policy,
                        color: Colors.black,
                      ),
                      title: Text(
                        "Privacy Policy",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AboutUsPage()));
                    },
                    child: const ListTile(
                      leading: Icon(
                        Icons.article,
                        color: Colors.black,
                      ),
                      title: Text(
                        "About Us",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const TermsAndConditionsPage()));
                    },
                    child: const ListTile(
                      leading: Icon(
                        Icons.question_answer,
                        color: Colors.black,
                      ),
                      title: Text(
                        "Terms and Conditions",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await alert(context);
                    },
                    child: const ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: Colors.black,
                      ),
                      title: Text(
                        "Logout",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
