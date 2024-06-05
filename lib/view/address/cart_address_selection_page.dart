import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:time_peace_project/model/address_model.dart';
import 'package:time_peace_project/view/address/add_address.dart';
import 'package:time_peace_project/view/checkout_page/checkout_page.dart';
import '../../model/cart_model.dart';
import 'edit_address_page.dart';

class CartAddressSelectionPage extends StatefulWidget {
  final List<Cart> cartData;

  const CartAddressSelectionPage({super.key, required this.cartData});

  @override
  State<CartAddressSelectionPage> createState() => _CartAddressSelectionPageState();
}

class _CartAddressSelectionPageState extends State<CartAddressSelectionPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Select the Addresse"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddAddressPage()));
              },
              child: Container(
                width: size.width / 1.04,
                height: size.height / 13,
                color: const Color.fromARGB(255, 210, 208, 208),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "Add address",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.add)
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('addresses')
                  .where('userId',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const SizedBox.shrink();
                }

                final List<DocumentSnapshot> documents = snapshot.data!.docs;

                if (documents.isEmpty) {
                  return Center(
                    child: Text(
                      'No address Added',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );
                }

                List<Address> addresses = snapshot.data!.docs
                    .map((doc) => Address.fromDocument(
                        doc.data() as Map<String, dynamic>, doc.id))
                    .toList();

                return ListView.builder(
                    itemCount: addresses.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            title: Text(
                              addresses[index].userName,
                              style: TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              addresses[index].address,
                              style: TextStyle(color: Colors.white),
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditAddressPage(
                                        addressId: addresses[index].id,
                                      ),
                                    ),
                                  );
                                } else if (value == 'delete') {
                                  _deleteAddress(addresses[index].id);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Proceed to GlobalCheckoutPage with the selected address and product
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutPage(
                                   cartData: widget.cartData,
                                    address: addresses[index],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAddress(String addressId) async {
    try {
      await FirebaseFirestore.instance
          .collection('addresses')
          .doc(addressId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete address: $e')),
      );
    }
  }
}
