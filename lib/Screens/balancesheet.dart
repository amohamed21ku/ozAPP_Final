import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oz/Screens/sheet.dart';
import '../Widgets/components.dart';
import '../Widgets/infocard.dart';
import '../models/Customers.dart';

class BalanceSheet extends StatefulWidget {
  const BalanceSheet({super.key});

  @override
  State<BalanceSheet> createState() => _BalanceSheetState();
}

class _BalanceSheetState extends State<BalanceSheet> {
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  bool showSpinner = false;
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    fetchCustomers();
    filterData(searchController.text);
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
      customers.clear(); // Clear existing data
      for (var doc in querySnapshot.docs) {
        final cid = doc.id;
        final name = doc['name'] as String;
        final company = doc['company'] as String;
        final initial =
            name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '';
        final Map<String, dynamic> items = doc['items'] as Map<String, dynamic>;
        customers.add(Customer(
            name: name,
            company: company,
            initial: initial,
            items: items,
            goods: {},
            cid: cid));
      }
    } catch (error) {
      // Handle any errors here
    }

    setState(() {
      showSpinner = false; // Hide loading HUD
    });
  }

  Future<void> _handleRefresh() async {
    await fetchCustomers();
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
          'Balance Sheet List',
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
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
                        // shrinkWrap: true,
                        itemCount: filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];
                          return InfoCard(
                            name: customer.name,
                            company: customer.company,
                            onpress: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ordersSheet(
                                  customerName: customer.name,
                                ),
                              ));
                            },
                            initial: customer.initial,
                            customerId: customer.cid,
                            isUser: true,
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
