import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oz/Screens/sheet.dart';
import '../models/Customers.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('orders').get();
      setState(() {
        orders = snapshot.docs.map((doc) {
          return {
            'orderNumber': doc['order_number'],
            'total': doc['total'],
            'customerId': doc['customer_id'],
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching orders: $e");
    }
  }

  double _calculateTotalOrders() {
    double total = 0;
    for (var order in orders) {
      total += order['total'];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffa4392f),
        title: Text(
          'Orders',
          style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: const Color(0x29a4392f),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Orders: \$${_calculateTotalOrders().toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return GestureDetector(
                          onTap: () async {
                            // Fetch the customer associated with this order
                            DocumentSnapshot customerDoc = await _firestore
                                .collection('customers')
                                .doc(order['customerId'])
                                .get();

                            if (customerDoc.exists) {
                              // Navigate to the order sheet with customer data
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ordersSheet(
                                    customer: Customer(
                                      cid: customerDoc['cid'],
                                      name: customerDoc['name'],
                                      company: customerDoc['company'],
                                      initial: "",
                                      items: customerDoc['items'],
                                      goods: customerDoc['goods'],
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Card(
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text(
                                'Order #${order['orderNumber']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Total: \$${order['total'].toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
