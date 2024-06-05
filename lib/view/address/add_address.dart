import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddAddressPage extends StatefulWidget {
  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _zipController = TextEditingController();

  final _firestore = FirebaseFirestore.instance;
  final email = FirebaseAuth.instance.currentUser!.email;
  final _auth = FirebaseAuth.instance;

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('addresses').add({
            'userId': user.uid,
            "email": email,
            "userName": _nameController.text,
            'address': _addressController.text,
            'district': _districtController.text,
            'city': _cityController.text,
            'state': _stateController.text,
            'zip': _zipController.text,
            'timestamp': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Address saved successfully!')),
          );

          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not logged in')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save address: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(labelText: 'City'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _districtController,
                decoration: InputDecoration(labelText: 'District'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your district';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _zipController,
                decoration: InputDecoration(labelText: 'Zip Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your zip code';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _stateController,
                decoration: InputDecoration(labelText: 'State'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your state';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAddress,
                child: Text('Save Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
