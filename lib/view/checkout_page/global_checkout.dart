import 'package:action_slider/action_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_peace_project/view/dash_screen/dash.dart';
import '../../model/address_model.dart';
import '../../model/productmodel.dart';

class GlobalCheckoutPage extends StatefulWidget {
  final Product product;
  final Address address;
  const GlobalCheckoutPage(
      {super.key, required this.product, required this.address});

  @override
  State<GlobalCheckoutPage> createState() => _GlobalCheckoutPageState();
}

class _GlobalCheckoutPageState extends State<GlobalCheckoutPage> {
  late double totalPrice;
  int quantity = 1;
  int deliveryCharge =
      50; // Assuming this is in the smallest unit (e.g., paise for INR)
  late int finalAmount;
  late Razorpay _razorpay;
  final user = FirebaseAuth.instance.currentUser;
  final keyPayment = "rzp_test_axqF2g1jF9fDHR";
  final secretKey = "Ps1tTp7bGoESouyIbIkevuQl";

  @override
  void initState() {
    super.initState();
    totalPrice = widget.product.price +
        deliveryCharge /
            100; // Assuming product price is in main unit (e.g., INR)

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear(); // Removes all listeners
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Store the order in Firestore
    await _createOrderInFirestore(response);

    // Navigate to Dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Dash()),
    );

    // Show success message
    Fluttertoast.showToast(msg: "Payment Successful");
    print("Payment Success: ${response.paymentId}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Show error message
    Fluttertoast.showToast(msg: "Payment Failed");
    print("Payment Error: ${response.code} - ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet: ${response.walletName}");
  }

  Future<void> _createOrderInFirestore(PaymentSuccessResponse response) async {
    try {
      // Get a reference to the product document
      DocumentReference productRef = FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id);

      // Start a Firestore transaction
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Get the current product data
        DocumentSnapshot productSnapshot = await transaction.get(productRef);

        if (!productSnapshot.exists) {
          throw Exception("Product does not exist!");
        }

        int currentQuantity = productSnapshot['quantity'];

        if (currentQuantity < quantity) {
          throw Exception("Insufficient product quantity!");
        }

        // Decrease the product quantity
        transaction
            .update(productRef, {'quantity': currentQuantity - quantity});

        // Add the order to the orders collection
        transaction.set(FirebaseFirestore.instance.collection('orders').doc(), {
          'userId': user!.uid,
          'email': user!.email,
          'productId': widget.product.id,
          'productName': widget.product.productName,
          'price': widget.product.price,
          'quantity': quantity,
          'deliveryCharge': deliveryCharge / 100,
          'totalPrice': totalPrice,
          'paymentId': response.paymentId,
          'address': widget.address.toMap(),
          'orderStatus': 'Pending', // Initial order status
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      print('Failed to create order: $e');
      Fluttertoast.showToast(msg: "Failed to create order: $e");
    }
  }

  void _openCheckout() {
    var options = {
      'key': keyPayment,
      'amount': finalAmount,
      'name': 'Acme Corp.',
      'description': 'Fine T-Shirt',
      'prefill': {'contact': '6238491980', 'email': user!.email.toString()},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('G Checkout'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Order Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: SizedBox()),
          ListTile(
            title: Text(widget.product.productName),
            subtitle: Text(
                ' ${quantity} x ₹${widget.product.price.toStringAsFixed(2)}'),
            trailing: Text(
                ' ₹${(quantity * widget.product.price).toStringAsFixed(2)}'),
          ),
          ListTile(
            title: Text("Delivery charge "),
            trailing: Text(
                ' ₹${(deliveryCharge).toStringAsFixed(2)}'), // Show delivery charge in main currency unit
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 25,
                ),
                Text(
                  '₹${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              bottom: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ActionSlider.standard(
                  sliderBehavior: SliderBehavior.stretch,
                  width: size.width / 1.07,
                  height: size.height / 10.8,
                  backgroundColor: Colors.black,
                  toggleColor: Colors.white,
                  icon: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 30,
                  ),
                  action: (controller) async {
                    controller.loading(); //starts loading animation
                    await Future.delayed(const Duration(seconds: 3));
                    controller.success(); //starts success animation
                    await Future.delayed(const Duration(seconds: 1));
                    controller.reset();
                    //resets the slider

                    finalAmount = (totalPrice * 100).toInt();
                    _openCheckout();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 35,
                      ),
                      Text(
                        'Proceed to pay',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



