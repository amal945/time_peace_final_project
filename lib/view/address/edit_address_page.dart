import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditAddressPage extends StatefulWidget {
  final String addressId;

  const EditAddressPage({Key? key, required this.addressId}) : super(key: key);

  @override
  _EditAddressPageState createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _zipController = TextEditingController();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _loadAddressData();
  }

  Future<void> _loadAddressData() async {
    DocumentSnapshot doc =
        await _firestore.collection('addresses').doc(widget.addressId).get();
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = data['userName'];
        _addressController.text = data['address'];
        _cityController.text = data['city'];
        _stateController.text = data['state'];
        _districtController.text = data['district'];
        _zipController.text = data['zip'];
      });
    }
  }

  Future<void> _updateAddress() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore
              .collection('addresses')
              .doc(widget.addressId)
              .update({
            'userName': _nameController.text,
            'address': _addressController.text,
            'city': _cityController.text,
            'state': _stateController.text,
            'district': _districtController.text,
            'zip': _zipController.text,
            'timestamp': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Address updated successfully!')),
          );

          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not logged in')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update address: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Address'),
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
                onPressed: _updateAddress,
                child: Text('Update Address'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
