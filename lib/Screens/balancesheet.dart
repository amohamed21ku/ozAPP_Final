import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../Widgets/infocard.dart';
import '../models/Customers.dart';
import 'spreedsheet.dart';

class BalanceSheet extends StatefulWidget {
  const BalanceSheet({super.key});

  @override
  State<BalanceSheet> createState() => _BalanceSheetState();
}

class _BalanceSheetState extends State<BalanceSheet> {
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
        padding: const EdgeInsets.all(10.0),
        child: ModalProgressHUD(
          progressIndicator: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xffa4392f)), // Change spinner color to theme color
            strokeWidth: 5.0, // Adjust spinner thickness if needed
          ),
          inAsyncCall: showSpinner,
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: const Color(
                0xffa4392f), // Change refresh indicator color to theme color
            backgroundColor: Colors
                .grey[200], // Change background color of refresh indicator
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                return InfoCard(
                  name: customer.name,
                  company: customer.company,
                  onpress: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Spreadsheet(
                        customer: customer,
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
        ),
      ),
    );
  }
}
