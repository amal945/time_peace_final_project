import 'package:cloud_firestore/cloud_firestore.dart';

class Orders {
  final String orderId;
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double deliveryCharge;
  final double totalPrice;
  final List<String> orderStatus;
  final List<String> statusTimes;
  final String timestamp;

  Orders({
    required this.statusTimes,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.deliveryCharge,
    required this.totalPrice,
    required this.orderStatus,
    required this.timestamp,
  });

  factory Orders.fromDocument(DocumentSnapshot doc) {
    return Orders(
      orderId: doc.id,
      productId: doc['productId'],
      productName: doc['productName'],
      price: doc['price'].toDouble(),
      quantity: doc['quantity'],
      deliveryCharge: doc['deliveryCharge'].toDouble(),
      totalPrice: doc['totalPrice'].toDouble(),
      orderStatus: List<String>.from(doc['orderStatus']),
      statusTimes: List<String>.from(doc['statusTimes']),
      timestamp: doc['timestamp'],
    );
  }
}
