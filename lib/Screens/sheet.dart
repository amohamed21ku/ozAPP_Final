import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/Customers.dart';

class ordersSheet extends StatefulWidget {
  final Customer customer;

  const ordersSheet({super.key, required this.customer});

  @override
  _ordersSheetState createState() => _ordersSheetState();
}

class _ordersSheetState extends State<ordersSheet> {
  final List<Map<String, dynamic>> _data = [];
  final List<Map<String, dynamic>> _initialData = []; // To store initial data

  final List<TextEditingController> _descriptionControllers = [];
  final List<TextEditingController> _quantityControllers = [];
  final List<TextEditingController> _unitPriceControllers = [];
  final List<TextEditingController> _amountControllers = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  @override
  void dispose() {
    // Dispose of all controllers when the widget is disposed
    for (var controller in _descriptionControllers) {
      controller.dispose();
    }
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    for (var controller in _unitPriceControllers) {
      controller.dispose();
    }
    for (var controller in _amountControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewRow() {
    setState(() {
      _data.add({
        'description': '',
        'quantity': 0.0,
        'unitPrice': 0.0,
        'amount': 0.0,
      });
      _descriptionControllers.add(TextEditingController());
      _quantityControllers.add(TextEditingController());
      _unitPriceControllers.add(TextEditingController());
      _amountControllers.add(TextEditingController());
    });
  }

  // void _showDeleteConfirmationDialog(int index) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Confirm Delete'),
  //         content: Text('Are you sure you want to delete this row?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //             },
  //             child: Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //               _deleteRow(index); // Delete the row
  //             },
  //             child: Text(
  //               'Delete',
  //               style: TextStyle(color: Colors.red),
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //   dispose();
  // }

  void _deleteRow(int index) {
    setState(() {
      // Dispose of the controllers before removing them
      _descriptionControllers[index].dispose();
      _quantityControllers[index].dispose();
      _unitPriceControllers[index].dispose();
      _amountControllers[index].dispose();

      _descriptionControllers.removeAt(index);
      _quantityControllers.removeAt(index);
      _unitPriceControllers.removeAt(index);
      _amountControllers.removeAt(index);
      _data.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffa4392f),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: _onWillPop,
          //     () {
          //   // _saveData();
          //   Navigator.pop(context);
          // },
        ),
        actions: [
          IconButton(
              icon: const Icon(
                Icons.add_box_rounded,
                color: Colors.white,
                size: 25,
              ),
              onPressed: _addNewRow),
        ],
        title: Text(
          'Balance Sheet',
          style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: const Color(0x29a4392f),
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 0,
                            blurRadius: 0,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person,
                            color: Color(0xdda4392f),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.customer.name,
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87

                                // color: const Color(0xdda4392f),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              _buildDataTable(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0x29a4392f),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL:',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                      Text(
                        '\$${_calculateTotalGoodsAmount().toStringAsFixed(2)}',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get the screen width using MediaQuery
        double screenWidth = MediaQuery.of(context).size.width;

        // Set proportional column widths based on the screen width
        double goodsColumnWidth =
            screenWidth * 0.4 + 15; // 40% of the screen width
        double quantityColumnWidth =
            screenWidth * 0.2; // 20% of the screen width
        double priceColumnWidth =
            screenWidth * 0.1 + 5; // 20% of the screen width
        double amountColumnWidth = screenWidth * 0.2; // 20% of the screen width

        return Table(
          border: TableBorder.all(
            color: Colors.black, // Border color (similar to gridlines in Excel)
            width: 0.5, // Border width
          ),
          columnWidths: {
            0: FixedColumnWidth(goodsColumnWidth), // Width for 'Goods' column
            1: FixedColumnWidth(
                quantityColumnWidth), // Width for 'Quantity' column
            2: FixedColumnWidth(priceColumnWidth), // Width for 'Price' column
            3: FixedColumnWidth(amountColumnWidth), // Width for 'Amount' column
          },
          children: [
            // Header Row
            TableRow(
              decoration: const BoxDecoration(
                  color: Color(0xffa4392f)), // Red header background
              children: [
                _buildHeaderCell('Goods'),
                _buildHeaderCell('Quantity'),
                _buildHeaderCell('Price'),
                _buildHeaderCell('Amount'),
              ],
            ),
            // Data Rows
            for (int index = 0; index < _data.length; index++)
              TableRow(
                children: [
                  GestureDetector(
                    onDoubleTap: () {
                      _deleteRow(index);
                    },
                    child: _buildEditableCell(
                        _descriptionControllers[index], index, 'description'),
                  ),
                  _buildEditableCell(
                      _quantityControllers[index], index, 'quantity'),
                  _buildEditableCell(
                      _unitPriceControllers[index], index, 'unitPrice'),
                  _buildEditableCell(
                      _amountControllers[index], index, 'amount'),
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderCell(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildEditableCell(
      TextEditingController controller, int index, String field) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: controller,
        keyboardType:
            (field == 'quantity' || field == 'unitPrice' || field == 'amount')
                ? TextInputType.numberWithOptions(signed: true, decimal: true)
                : TextInputType.text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: (field == 'amount' || field == "description")
              ? FontWeight.w500
              : FontWeight.w300,
          color: (field == 'amount' && _data[index]['amount'] < 0)
              ? Colors.red // Change color to red if amount is negative
              : Colors.black, // Default color for other cases
        ),
        cursorColor: const Color(0xffa4392f),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          prefixText: field == 'unitPrice'
              ? '\$'
              : (field == 'amount')
                  ? '\$ '
                  : null,
        ),
        onChanged: (value) {
          setState(() {
            if (field == 'quantity' || field == 'unitPrice') {
              double parsedValue = double.tryParse(value) ?? 0.0;
              _data[index][field] = parsedValue;
              _data[index]['amount'] =
                  _data[index]['quantity'] * _data[index]['unitPrice'];
              _amountControllers[index].text =
                  _data[index]['amount'].toStringAsFixed(2);
            } else if (field == 'amount') {
              _data[index]['amount'] = double.tryParse(value) ?? 0.0;
            } else {
              _data[index][field] = value;
            }
          });
        },
      ),
    );
  }

  double _calculateTotalGoodsAmount() {
    double total = 0;
    for (var row in _data) {
      total += row['amount'];
    }
    return total;
  }

  Future<void> _saveData() async {
    List<Map<String, dynamic>> updatedGoods = [];

    for (int i = 0; i < _data.length; i++) {
      double? quantity = _data[i]['quantity']?.toDouble();
      double? unitPrice = _data[i]['unitPrice']?.toDouble();
      double? amount = _data[i]['amount']?.toDouble();

      // Check if both quantity and unitPrice are 0 while amount is not 0
      if (quantity == 0 && unitPrice == 0 && amount != 0) {
        quantity = null; // Assign null to represent an empty state
        unitPrice = null; // Assign null to represent an empty state
      }

      updatedGoods.add({
        'goods_descriptions': _data[i]['description'],
        'quantity': quantity, // Can be null if empty
        'unit_price': unitPrice, // Can be null if empty
        'amount': amount, // Can be null if empty
        'index': i // Store the index to preserve order
      });
    }

    // Perform the save operation to Firestore
    await _firestore.collection('customers').doc(widget.customer.cid).update({
      'goods': updatedGoods,
    });

    // Check if the widget is still mounted before updating the UI
    if (!mounted) return;

    // Display a success message using the ScaffoldMessenger
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Data saved successfully!',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xffa4392f), // Match the app theme color
        duration: const Duration(seconds: 1), // Display duration
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchData(widget.customer);
  }

  Future<void> _fetchData(Customer customer) async {
    setState(() => isLoading = true);

    DocumentSnapshot customerDoc =
        await _firestore.collection('customers').doc(customer.cid).get();
    if (customerDoc.exists) {
      List<dynamic> goods = customerDoc['goods'];

      // Clear the existing data and controllers
      _data.clear();
      _descriptionControllers.clear();
      _quantityControllers.clear();
      _unitPriceControllers.clear();
      _amountControllers.clear();

      for (var value in goods) {
        double? quantity = value['quantity']?.toDouble();
        double? unitPrice = value['unit_price']?.toDouble();
        double? amount = value['amount']?.toDouble();

// Check if quantity and unitPrice are both 0 and amount is not 0
        if (quantity == 0 && unitPrice == 0 && amount != 0) {
          quantity = null; // Assign null to represent an empty state
          unitPrice = null; // Assign null to represent an empty state
          // amount remains as it is
        }

        // Add the fetched data in order
        _data.add({
          'description': value['goods_descriptions'],
          'quantity': quantity,
          'unitPrice': unitPrice,
          'amount': amount,
        });

        // Update the controllers to reflect the fetched data
        _descriptionControllers
            .add(TextEditingController(text: value['goods_descriptions']));
        _quantityControllers
            .add(TextEditingController(text: quantity?.toString() ?? ''));
        _unitPriceControllers
            .add(TextEditingController(text: unitPrice?.toString() ?? ''));
        _amountControllers
            .add(TextEditingController(text: amount?.toString() ?? ''));
      }
    }
    // Save the initial data for comparison
    // Deep copy the initial data
    // Clear previous initial data if any
    _initialData.clear();

// Deep copy each map in _data to _initialData
    _initialData
        .addAll(_data.map((item) => Map<String, dynamic>.from(item)).toList());

    print("First: $_initialData");

    setState(() => isLoading = false);
  }

  Future<bool> _checkForChanges() async {
    // Check if a new item was added or removed
    if (_data.length != _initialData.length) {
      return true; // A row was added or removed, so it's a change
    }

    // Check if any item values were changed
    for (int i = 0; i < _data.length; i++) {
      if (_data[i]['description'] != _initialData[i]['description'] ||
          _data[i]['quantity'] != _initialData[i]['quantity'] ||
          _data[i]['unitPrice'] != _initialData[i]['unitPrice'] ||
          _data[i]['amount'] != _initialData[i]['amount']) {
        return true; // There are changes
      }
    }

    return false; // No changes
  }

  Future<void> _onWillPop() async {
    bool hasChanges = await _checkForChanges();
    if (hasChanges) {
      bool? save = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // Rounded corners
            ),
            backgroundColor: Colors.white, // Background color
            title: Text(
              'Unsaved Changes',
              style: GoogleFonts.poppins(
                color: const Color(0xffa4392f), // Title text color
                fontWeight: FontWeight.bold, // Bold styling for emphasis
              ),
            ),
            content: Text(
              'Do you want to save your changes?',
              style: GoogleFonts.poppins(
                color: Colors.black87, // Content text color
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // Don't save
                    },
                    child: Text(
                      'No',
                      style: GoogleFonts.poppins(
                        color:
                            const Color(0xffa4392f), // 'No' button text color
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _saveData(); // Save data
                      Navigator.of(context).pop(true); // Save and exit
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                          0xffa4392f), // 'Yes' button background color
                    ),
                    child: Text(
                      'Yes',
                      style: GoogleFonts.poppins(
                        color: Colors.white, // 'Yes' button text color
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );

      if (save ?? false) {
        _saveData();
      }
    }
    Navigator.pop(context);
  }
}
