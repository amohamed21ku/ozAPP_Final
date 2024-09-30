import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Widgets/components.dart';
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
  List<Customer> filteredCustomers = [];
  bool showSpinner = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCustomers();
    searchController.addListener(() {
      filterData(searchController.text);
    });
  }

  Future<void> _editCustomer(BuildContext context, Customer customer) async {
    String updatedName = customer.name;
    String updatedCompany = customer.company;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Edit Customer Info',
            style: GoogleFonts.poppins(
              color: const Color(0xffa4392f), // Title color
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle:
                        TextStyle(color: Color(0xffa4392f)), // Label color
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(
                              0xffa4392f)), // Underline color when focused
                    ),
                  ),
                  cursorColor: const Color(0xffa4392f), // Cursor color
                  controller: TextEditingController(text: customer.name),
                  onChanged: (value) => updatedName = value,
                ),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Company',
                    labelStyle:
                        TextStyle(color: Color(0xffa4392f)), // Label color
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(
                              0xffa4392f)), // Underline color when focused
                    ),
                  ),
                  cursorColor: const Color(0xffa4392f), // Cursor color
                  controller: TextEditingController(text: customer.company),
                  onChanged: (value) => updatedCompany = value,
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog without saving
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
                    // Update customer info in Firestore
                    await FirebaseFirestore.instance
                        .collection('customers')
                        .doc(customer.cid)
                        .update({
                      'name': updatedName,
                      'company': updatedCompany,
                    });

                    Navigator.of(context).pop(); // Close dialog after saving
                    await fetchCustomers(); // Refresh customer list
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xffa4392f), // Button background color
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      color: Colors.white, // Button text color
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Filtering function
  void filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCustomers =
            customers; // Show all customers when search is empty
      } else {
        filteredCustomers = customers
            .where((customer) =>
                customer.name.toLowerCase().contains(query.toLowerCase()) ||
                customer.company.toLowerCase().contains(query.toLowerCase()))
            .toList(); // Filter customers by name or company
      }
    });
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

      // Initialize filteredCustomers with all customers_
      filteredCustomers = customers;

      // Cache the customer data
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('customers',
          jsonEncode(customers.map((customer) => customer.toJson()).toList()));
    } catch (error) {
      // Handle error here if needed
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
    List goods = [];
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
          content: SizedBox(
            width: double.maxFinite,
            // height: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle:
                        TextStyle(color: Color(0xffa4392f)), // Label color
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(
                              0xffa4392f)), // Underline color when focused
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
                          color: Color(
                              0xffa4392f)), // Underline color when focused
                    ),
                  ),
                  cursorColor: const Color(0xffa4392f), // Cursor color
                  onChanged: (value) => company = value,
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
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
                    await FirebaseFirestore.instance
                        .collection('customers')
                        .add({
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
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_box_rounded,
              color: Colors.white,
              size: 25,
            ),
            onPressed: () {
              _addCustomer(context);
            },
          ),
        ],
        title: Text(
          'Customers List',
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: const Color(0xffa4392f),
      //   onPressed: () => _addCustomer(context),
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: showSpinner
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xffa4392f)),
                ),
              )
            : RefreshIndicator(
                onRefresh: _handleRefresh,
                color: const Color(0xffa4392f),
                backgroundColor: Colors.grey[200],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSearchBar(
                      searchController: searchController,
                      onChanged: filterData,
                      hinttext: 'Search by Name or Company',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          return GestureDetector(
                            onLongPress: () {
                              // edit the customer info
                              _editCustomer(context, customer);
                            },
                            child: InfoCard(
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
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(
                          height: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
