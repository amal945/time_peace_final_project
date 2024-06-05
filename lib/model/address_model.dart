import 'package:cloud_firestore/cloud_firestore.dart';

class Address {
  String id;
  String userId;
  String address;
  String city;
  String state;
  String zip;
  String country;
  String userName;
  DateTime? timestamp;

  Address({
    required this.id,
    required this.userName,
    required this.userId,
    required this.address,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
    this.timestamp,
  });

  // Convert a Firestore document to an Address object
  factory Address.fromDocument(Map<String, dynamic> doc, String docId) {
    return Address(
      userName: doc["userName"],
      id: docId,
      userId: doc['userId'] ?? '',
      address: doc['address'] ?? '',
      city: doc['city'] ?? '',
      state: doc['state'] ?? '',
      zip: doc['zip'] ?? '',
      country: doc['country'] ?? '',
      timestamp: doc['timestamp'] != null
          ? (doc['timestamp'] as Timestamp).toDate()
          : null,
    );
  }

  // Convert an Address object to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'address': address,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
      'timestamp': timestamp,
    };
  }
}
