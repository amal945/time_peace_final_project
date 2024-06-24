import 'package:action_slider/action_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:time_peace_project/view/dash_screen/dash.dart';
import '../../model/address_model.dart';
import '../../model/cart_model.dart';
import 'package:intl/intl.dart';

class CheckoutPage extends StatefulWidget {
  final List<Cart> cartData;
  final Address address;

  const CheckoutPage({Key? key, required this.cartData, required this.address})
      : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  late double totalPrice;
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
    totalPrice = widget.cartData
        .fold(0.0, (sum, cart) => sum + (cart.price * cart.quantity));
    totalPrice += deliveryCharge;

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
      // Start a Firestore transaction
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        List<Map<String, dynamic>> productUpdates = [];
        List<Map<String, dynamic>> orderData = [];

        for (var cart in widget.cartData) {
          // Get a reference to the product document
          DocumentReference productRef = FirebaseFirestore.instance
              .collection('products')
              .doc(cart.productId);

          // Get the current product data within the transaction
          DocumentSnapshot productSnapshot = await transaction.get(productRef);

          if (!productSnapshot.exists) {
            throw Exception("Product does not exist!");
          }

          int currentQuantity = productSnapshot['quantity'];

          if (currentQuantity < cart.quantity) {
            throw Exception(
                "Insufficient product quantity for ${cart.productName}!");
          }

          // Prepare the product update data
          productUpdates.add({
            'ref': productRef,
            'newQuantity': currentQuantity - cart.quantity,
          });

          // Get current date and time as a string
          String currentTime =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

          // Prepare the order data
          orderData.add({
            'userId': user!.uid,
            'email': user!.email,
            'productId': cart.productId,
            'productName': cart.productName,
            'price': cart.price,
            'quantity': cart.quantity,
            'deliveryCharge': deliveryCharge,
            'totalPrice': cart.price * cart.quantity,
            'paymentId': response.paymentId,
            'address': widget.address.toMap(),
            'orderStatus': ["Order Placed"],
            'statusTimes': [currentTime],
            'timestamp': currentTime,
          });
        }

        // Execute all the writes within the transaction
        for (var productUpdate in productUpdates) {
          transaction.update(productUpdate['ref'], {
            'quantity': productUpdate['newQuantity'],
          });
        }

        for (var order in orderData) {
          transaction.set(
              FirebaseFirestore.instance.collection('orders').doc(), order);
        }
      });

      // If transaction succeeds, delete cart items for the user
      await _deleteCartItems();

      print("Order created successfully");
    } catch (e, stackTrace) {
      print('Failed to create order: $e');
      Fluttertoast.showToast(msg: "Failed to create order: $e");

      // Print or log the stack trace for more details
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _deleteCartItems() async {
    try {
      // Query and delete cart items for the current user
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("cart")
          .where("email", isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get();

      // Delete each document found in the query
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
        print('Document ${doc.id} deleted successfully');
      }
    } catch (e) {
      print('Failed to delete cart items: $e');
      // Handle the error as needed
    }
  }

  void _openCheckout() {
    finalAmount = (totalPrice * 100)
        .toInt(); // Convert to smallest currency unit (e.g., paise)

    var options = {
      'key': keyPayment,
      'amount': finalAmount,
      'name': 'Acme Corp.',
      'description': 'Cart Purchase',
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
        title: const Text('Checkout'),
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
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartData.length,
              itemBuilder: (context, index) {
                final product = widget.cartData[index];
                return ListTile(
                  title: Text(product.productName),
                  subtitle: Text(
                      '${product.quantity} x ₹${product.price.toStringAsFixed(2)}'),
                  trailing: Text(
                      '₹${(product.quantity * product.price).toStringAsFixed(2)}'),
                );
              },
            ),
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
