import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final String docId; // Document ID

  const ItemDetailsScreen({super.key, required this.item, required this.docId});

  @override
  _ItemDetailsScreenState createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  TextEditingController koduController = TextEditingController();
  TextEditingController kaliteController = TextEditingController();
  TextEditingController eniController = TextEditingController();
  TextEditingController gramajController = TextEditingController();
  TextEditingController supplierController = TextEditingController();
  TextEditingController itemNoController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  List<Map<String, dynamic>> previousPrices = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    koduController.text = widget.item['Kodu'] ?? '';
    kaliteController.text = widget.item['Kalite'] ?? '';
    eniController.text = widget.item['Eni'] ?? '';
    gramajController.text = widget.item['Gramaj'] ?? '';
    supplierController.text = widget.item['Supplier'] ?? '';
    itemNoController.text = widget.item['Item No.'] ?? '';
    nameController.text = widget.item['Item Name'] ?? '';
    priceController.text = widget.item['Price'] ?? '';
    dateController.text = widget.item['Date'] ?? '';

    // Initialize previous prices
    // if (widget.item.containsKey('Previous_Prices')) {
    //   String previousPricesString = widget.item['Previous_Prices'];
    //   Map<String, dynamic> previousPricesMap = jsonDecode(previousPricesString);
    //   previousPrices = previousPricesMap.entries.map((entry) {
    //     return {
    //       'date': DateTime.now(), // Replace with the actual date if available
    //       'price_1_1': previousPricesMap['price_1_1'] ?? '',
    //       'price_1_2': previousPricesMap['price_1_2'] ?? '',
    //       'price_1_3': previousPricesMap['price_1_3'] ?? '',
    //       'price_2_1': previousPricesMap['price_2_1'] ?? '',
    //       'price_2_2': previousPricesMap['price_2_2'] ?? '',
    //       'price_2_3': previousPricesMap['price_2_3'] ?? '',
    //       'price_3_1': previousPricesMap['price_3_1'] ?? '',
    //       'price_3_2': previousPricesMap['price_3_2'] ?? '',
    //       'price_3_3': previousPricesMap['price_3_3'] ?? '',
    //     };
    //   }).toList();
    // }
  }

  Future<void> updateItemData() async {
    // Prepare updated data
    Map<String, dynamic> itemData = {
      'Kodu': koduController.text,
      'Kalite': kaliteController.text,
      'Eni': eniController.text,
      'Gramaj': gramajController.text,
      'Supplier': supplierController.text,
      'Item No.': itemNoController.text,
      'Item Name': nameController.text,
      'Price': priceController.text,
      'Date': dateController.text,
      // 'Previous_Prices': jsonEncode(previousPrices),
    };

    try {
      await FirebaseFirestore.instance
          .collection('items')
          .doc(widget.docId) // Use the document ID received from ItemsScreen
          .update(itemData);

      // Show success message or navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item updated successfully'),
        ),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update item: $e'),
        ),
      );
    }
  }

  void addNewPrice() {
    setState(() {
      previousPrices.add({
        'date': DateTime.now(), // Default to current date
        'price_1_1': '', // Empty price initially
        'price_1_2': '',
        'price_1_3': '',
        'price_2_1': '',
        'price_2_2': '',
        'price_2_3': '',
        'price_3_1': '',
        'price_3_2': '',
        'price_3_3': '',
      });
    });
  }

  void removePrice(int index) {
    setState(() {
      previousPrices.removeAt(index);
    });
  }

  Future<void> showDatePickerAndSetDate(int index) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        previousPrices[index]['date'] = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        actions: [
          IconButton(
            onPressed: updateItemData,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: koduController,
              decoration: const InputDecoration(labelText: 'Kodu'),
            ),
            TextField(
              controller: kaliteController,
              decoration: const InputDecoration(labelText: 'Kalite'),
            ),
            TextField(
              controller: eniController,
              decoration: const InputDecoration(labelText: 'Eni'),
            ),
            TextField(
              controller: gramajController,
              decoration: const InputDecoration(labelText: 'Gramaj'),
            ),
            TextField(
              controller: supplierController,
              decoration: const InputDecoration(labelText: 'Supplier'),
            ),
            TextField(
              controller: itemNoController,
              decoration: const InputDecoration(labelText: 'Item No.'),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Date'),
            ),
            const SizedBox(height: 20),
            Text(
              'Previous Prices',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Center(
                        child: Text(
                          'USD',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Center(
                        child: Text(
                          'C/F',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Center(
                        child: Text(
                          'Tarih',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    TableCell(
                      child: Center(
                        child: Text(
                          'Actions',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                for (var i = 0; i < previousPrices.length; i++)
                  TableRow(
                    children: [
                      TableCell(
                        child: TextField(
                          controller: TextEditingController(
                            text: previousPrices[i]['price_1_1'],
                          ),
                          onChanged: (value) {
                            setState(() {
                              previousPrices[i]['price_1_1'] = value;
                            });
                          },
                        ),
                      ),
                      TableCell(
                        child: TextField(
                          controller: TextEditingController(
                            text: previousPrices[i]['price_1_2'],
                          ),
                          onChanged: (value) {
                            setState(() {
                              previousPrices[i]['price_1_2'] = value;
                            });
                          },
                        ),
                      ),
                      TableCell(
                        child: TextField(
                          controller: TextEditingController(
                            text: previousPrices[i]['price_1_3'],
                          ),
                          onChanged: (value) {
                            setState(() {
                              previousPrices[i]['price_1_3'] = value;
                            });
                          },
                        ),
                      ),
                      TableCell(
                        child: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => removePrice(i),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addNewPrice,
              child: const Text('Add Price'),
            ),
          ],
        ),
      ),
    );
  }
}
