import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:time_peace_project/view/address/address.dart';
import 'package:time_peace_project/view/order_page/orders.dart';
import 'package:time_peace_project/widgets/constants.dart';

class ScreenAccount extends StatefulWidget {
  const ScreenAccount({super.key});

  @override
  State<ScreenAccount> createState() => _ScreenAccountState();
}

class _ScreenAccountState extends State<ScreenAccount> {
  String userName = "";

  Future<void> fetchUserName() async {
    User? user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      String email = user.email!;
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        setState(() {
          userName = userDoc['username'];
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 19.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Profile",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        kSize15,
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 52,
                child: Icon(
                  Icons.person_2_outlined,
                  size: 52,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Text(
                userName.isNotEmpty ? userName : "Loading...",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        kSize35,
        InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ScreenAddress()));
          },
          child: Container(
            width: size.width / 1.1,
            height: size.height / 13,
            color: const Color.fromARGB(255, 223, 220, 220),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 30,
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  Text(
                    "Saved Addresses",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ),
        kSize15,
        InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => OrdersPage()));
          },
          child: Container(
            width: size.width / 1.1,
            height: size.height / 13,
            color: const Color.fromARGB(255, 223, 220, 220),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.all_inbox,
                    size: 28,
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  Text(
                    "Orders",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
