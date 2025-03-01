import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Widgets/infocard.dart';
import '../models/Customers.dart';
import 'CustomerItemsList.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  bool showSpinner = false;
  bool isSearching = false; // Flag to toggle search mode

  TextEditingController searchController = TextEditingController();

  void toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        filterData(''); // Reset the filtered list when exiting search
      }
    });
  }

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
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20.0), // Rounded corners for the dialog
          ),
          backgroundColor: Colors.white, // Set background to white
          title: Text(
            'Edit Customer Info',
            style: GoogleFonts.poppins(
              color: const Color(0xffa4392f), // Title color in red
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: GoogleFonts.poppins(
                      color: const Color(0xffa4392f), // Label color in red
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xffa4392f), // Border color in red
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xffa4392f), // Focused border color in red
                      ),
                    ),
                  ),
                  cursorColor: const Color(0xffa4392f), // Cursor color in red
                  style: GoogleFonts.poppins(
                    color: Colors.black, // Text color in black
                  ),
                  controller: TextEditingController(text: customer.name),
                  onChanged: (value) => updatedName = value,
                ),
                const SizedBox(height: 16.0), // Space between fields
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Company',
                    labelStyle: GoogleFonts.poppins(
                      color: const Color(0xffa4392f), // Label color in red
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xffa4392f), // Border color in red
                      ),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xffa4392f), // Focused border color in red
                      ),
                    ),
                  ),
                  cursorColor: const Color(0xffa4392f), // Cursor color in red
                  style: GoogleFonts.poppins(
                    color: Colors.black, // Text color in black
                  ),
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
                      color:
                          const Color(0xffa4392f), // Button text color in red
                      fontWeight: FontWeight.w600,
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
                    backgroundColor: const Color(
                        0xffa4392f), // Button background color in red
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12.0), // Rounded button
                    ),
                  ),
                  child: Text(
                    'Save',
                    style: GoogleFonts.poppins(
                      color: Colors.white, // Button text color in white
                      fontWeight: FontWeight.w600,
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
      showSpinner = true;
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
      customers.sort((a, b) => a.name.compareTo(b.name)); // Sort alphabetically
      filteredCustomers = customers;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('customers',
          jsonEncode(customers.map((customer) => customer.toJson()).toList()));
    } catch (error) {
      // Handle error here if needed
    }
    setState(() {
      showSpinner = false;
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Add Customer',
            style: GoogleFonts.poppins(
              color: const Color(0xffa4392f), // Title color in red
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: GoogleFonts.poppins(
                      color: const Color(0xffa4392f), // Label color in red
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            Color(0xffa4392f), // Underline color when focused
                      ),
                    ),
                  ),
                  cursorColor: const Color(0xffa4392f), // Cursor color in red
                  onChanged: (value) => name = value,
                  style: GoogleFonts.poppins(
                      color: Colors.black), // Input text color
                ),
                const SizedBox(height: 10), // Add spacing between fields
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Company',
                    labelStyle: GoogleFonts.poppins(
                      color: const Color(0xffa4392f), // Label color in red
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            Color(0xffa4392f), // Underline color when focused
                      ),
                    ),
                  ),
                  cursorColor: const Color(0xffa4392f), // Cursor color in red
                  onChanged: (value) => company = value,
                  style: GoogleFonts.poppins(
                      color: Colors.black), // Input text color
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
                      color:
                          const Color(0xffa4392f), // Button text color in red
                      fontWeight: FontWeight.w600,
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
                    backgroundColor: const Color(
                        0xffa4392f), // Button background color in red
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'Add',
                    style: GoogleFonts.poppins(
                      color: Colors.white, // Button text color in white
                      fontWeight: FontWeight.w600,
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
      backgroundColor: Colors.white,
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
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: toggleSearch,
          ),
          IconButton(
            icon: const Icon(
              Icons.add_box_rounded,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              _addCustomer(context);
            },
          ),
        ],
        title: isSearching
            ? TextField(
                cursorColor: Colors.white54,
                controller: searchController,
                autofocus: true,
                onChanged: filterData,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search by Kodu or Name',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              )
            : Text(
                "Customer List",
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          bool showInitialHeader = index == 0 ||
                              customer.initial !=
                                  filteredCustomers[index - 1].initial;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showInitialHeader)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 16.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        customer.initial,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              GestureDetector(
                                onLongPress: () {
                                  // Edit the customer info
                                  _editCustomer(context, customer);
                                },
                                child: Column(
                                  children: [
                                    InfoCard(
                                      name: customer.name,
                                      company: customer.company,
                                      onpress: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) =>
                                              CustomerListScreen(
                                            customerName: customer.name,
                                            customerId: customer.cid,
                                          ),
                                        ));
                                      },
                                      initial: customer.initial,
                                      customerId: customer.cid,
                                      isUser: false,
                                    ),
                                    SizedBox(
                                      height: 2,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
