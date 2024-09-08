import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Widgets/infocard.dart';
import '../models/Customers.dart';
import 'customer_items_screen.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  List<Customer> customers = [];
  bool showSpinner = false; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    setState(() {
      showSpinner = true; // Show loading HUD
    });

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('customers').get();
      customers = querySnapshot.docs.map((doc) {
        final name = doc['name'] as String;
        final company = doc['company'] as String;
        final initial =
            name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '';
        final Map<String, dynamic> items = doc['items'] as Map<String, dynamic>;
        final cid = doc.id;
        final goods = doc['goods'];
        return Customer(
          name: name,
          company: company,
          initial: initial,
          items: items,
          cid: cid,
          goods: goods,
        );
      }).toList();

      // Cache the customer data
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('customers',
          jsonEncode(customers.map((customer) => customer.toJson()).toList()));
    } catch (error) {
      // print('Error fetching customers: $error');
    }

    setState(() {
      showSpinner = false; // Hide loading HUD
    });
  }

  Future<void> _handleRefresh() async {
    await fetchCustomers();
  }

  Future<void> _addCustomer(BuildContext context) async {
    String name = '';
    String company = '';
    Map goods = {};
    Map items = {};

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Customer',
            style: GoogleFonts.poppins(
              color: const Color(0xffa4392f), // Title color
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle:
                      TextStyle(color: Color(0xffa4392f)), // Label color
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            Color(0xffa4392f)), // Underline color when focused
                  ),
                ),
                cursorColor: const Color(0xffa4392f), // Cursor color
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Company',
                  labelStyle:
                      TextStyle(color: Color(0xffa4392f)), // Label color
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            Color(0xffa4392f)), // Underline color when focused
                  ),
                ),
                cursorColor: const Color(0xffa4392f), // Cursor color
                onChanged: (value) => company = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without adding
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: const Color(0xffa4392f), // Button text color
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Add customer to Firestore
                await FirebaseFirestore.instance.collection('customers').add({
                  'name': name,
                  'company': company,
                  'goods': goods,
                  'items': items,
                  // Add other fields as needed
                });
                Navigator.of(context).pop(); // Close dialog after adding
                await fetchCustomers(); // Refresh customer list
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xffa4392f), // Button background color
              ),
              child: Text(
                'Add',
                style: GoogleFonts.poppins(
                  color: Colors.white, // Button text color
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xffa4392f),
        title: Text(
          'Customers List',
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffa4392f),
        onPressed: () => _addCustomer(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: showSpinner
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xffa4392f)), // Change spinner color to theme color
                ),
              )
            : RefreshIndicator(
                onRefresh: _handleRefresh,
                color: const Color(
                    0xffa4392f), // Change refresh indicator color to theme color
                backgroundColor: Colors
                    .grey[200], // Change background color of refresh indicator
                child: FutureBuilder(
                  future: SharedPreferences.getInstance(),
                  builder: (BuildContext context,
                      AsyncSnapshot<SharedPreferences> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    List<Customer> cachedCustomers = [];
                    try {
                      List<dynamic> jsonList =
                          jsonDecode(snapshot.data!.getString('customers')!);
                      cachedCustomers = jsonList
                          .map((item) => Customer.fromJson(item))
                          .toList();
                    } catch (error) {
                      // print('Error decoding cached customers: $error');
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: cachedCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = cachedCustomers[index];
                        return InfoCard(
                          name: customer.name,
                          company: customer.company,
                          onpress: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  CustomerItemsScreen(customer: customer),
                            ));
                          },
                          initial: customer.initial,
                          customerId: customer.cid,
                          isUser: false,
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(
                        height: 4,
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
