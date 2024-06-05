import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key, required this.amount});

  final int amount;

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late int finalAmount;
  late Razorpay _razorpay;
  final user = FirebaseAuth.instance.currentUser;
  final keyPayment = "rzp_test_axqF2g1jF9fDHR";
  final secretKey = "Ps1tTp7bGoESouyIbIkevuQl";

  @override
  void initState() {
    super.initState();
    finalAmount = widget.amount.toInt();

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

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    print("Payment Success: ${response.paymentId}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
    print("Payment Error: ${response.code} - ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
    print("External Wallet: ${response.walletName}");
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Razorpay Payment'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _openCheckout,
          child: Text('Open Razorpay Checkout'),
        ),
      ),
    );
  }
}
