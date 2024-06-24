import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text('About Us'),
      ),
      body:const Padding(
        padding:  EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About Us',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome to Time Peace Project!',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 8),
              Text(
                'At Time Peace Project, we are passionate about delivering high-quality watches to our customers. Our mission is to provide a wide range of stylish and reliable timepieces that cater to diverse tastes and preferences.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'We believe that a watch is more than just a timekeeping device; it\'s a statement of personal style and a reflection of one\'s personality. That\'s why we carefully curate our collection to include watches from renowned brands, as well as unique and innovative designs from emerging watchmakers.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Our team is dedicated to providing exceptional customer service, ensuring that your shopping experience with us is seamless and enjoyable. We are always here to assist you with any questions or concerns you may have.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Thank you for choosing Time Peace Project. We hope you find the perfect watch that suits your style and needs.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
