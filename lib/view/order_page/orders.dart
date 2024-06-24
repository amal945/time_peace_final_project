import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:time_peace_project/model/order_model.dart';
import 'package:time_peace_project/view/order_page/order_tracking.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('email', isEqualTo: user!.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          List<Orders> orders = snapshot.data!.docs
              .map((doc) => Orders.fromDocument(doc))
              .toList();
          print(orders.length);

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              Orders order = orders[index];
              bool isDelivered = order.orderStatus.last == "Delivered";
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.yellow)),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(order.productName),
                        subtitle: Text(
                          '${order.quantity} x ₹${order.price.toStringAsFixed(2)}\nStatus: ${order.orderStatus.last}',
                        ),
                        trailing:
                            Text('₹${(order.totalPrice).toStringAsFixed(2)}'),
                        isThreeLine: true,
                        onTap: () {
                          // Optionally, you can navigate to an order details page
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: isDelivered
                                  ? null
                                  : () {
                                      _showCancelDialog(order);
                                    },
                              child: Container(
                                width: size.width / 2.2,
                                height: size.height / 13,
                                decoration: BoxDecoration(
                                  color:
                                      isDelivered ? Colors.grey : Colors.blue,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
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
                                        OrderTracking(order: order),
                                  ),
                                );
                              },
                              child: Container(
                                width: size.width / 2.2,
                                height: size.height / 13,
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(16)),
                                child: const Center(
                                  child: Text(
                                    "Detail",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCancelDialog(Orders order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Cancel"),
          content: Text("Are you sure you want to cancel this order?"),
          actions: [
            TextButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Yes"),
              onPressed: () {
                _cancelOrder(order);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelOrder(Orders order) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(order.orderId)
          .delete();
      Fluttertoast.showToast(msg: "Order cancelled successfully.");
      Fluttertoast.showToast(
          msg: "Your money will be refunded in 3-7 business days");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to cancel order: $e");
    }
  }
}
