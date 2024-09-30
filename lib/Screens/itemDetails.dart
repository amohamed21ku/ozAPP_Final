import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/GsheetAPI.dart';
import 'itemsScreen.dart';

class ItemDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final String docId;
  final String SelectedItems;
  final int index;

  const ItemDetailsScreen(
      {super.key,
      required this.item,
      required this.docId,
      required this.SelectedItems,
      required this.index});

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
  TextEditingController NOTController = TextEditingController();
  TextEditingController CompositionController = TextEditingController();

  int _selectedPriceIndex = 0; // Default to the first entry

  List<dynamic> previousPrices = [];
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  void _confirmDelete(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      // If confirmed, delete from the list and Firestore
      setState(() {
        previousPrices.removeAt(index);
        if (_selectedPriceIndex == index) {
          _selectedPriceIndex = -1; // Reset selection
          priceController.clear();
          dateController.clear();
        } else if (_selectedPriceIndex > index) {
          _selectedPriceIndex--;
        }
      });

      try {
        await FirebaseFirestore.instance
            .collection(widget.SelectedItems)
            .doc(widget.docId)
            .update({'Previous_Prices': previousPrices});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Row deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete row: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize controllers with safe defaults
    koduController.text = widget.item['Kodu'] ?? '';
    kaliteController.text = widget.item['Kalite'] ?? '';
    eniController.text = widget.item['Eni'] ?? '';
    gramajController.text = widget.item['Gramaj'] ?? '';
    supplierController.text = widget.item['Supplier'] ?? '';
    itemNoController.text = widget.item['Item No'] ?? '';
    nameController.text = widget.item['Item Name'] ?? '';
    priceController.text = widget.item['Price'] ?? '';
    dateController.text = widget.item['Date'] ?? '';
    NOTController.text = widget.item['NOT'] ?? '';

    previousPrices = widget.item['Previous_Prices'] ?? [];
    if (widget.SelectedItems == 'Naylon')
      CompositionController.text = widget.item['Composition'] ?? '';

    // Set the default selected index based on matching values
    _selectedPriceIndex = -1; // Default to -1 (no selection)
    for (int i = 0; i < previousPrices.length; i++) {
      if (previousPrices[i]['price'] == priceController.text &&
          previousPrices[i]['date'] == dateController.text) {
        _selectedPriceIndex = i;
        break;
      }
    }

    if (_selectedPriceIndex != -1) {
      priceController.text = previousPrices[_selectedPriceIndex]['price'];
      dateController.text = previousPrices[_selectedPriceIndex]['date'];
    }
  }

  void _addRow() {
    setState(() {
      previousPrices.add({
        'price': '',
        'date': '',
        'C/F': '', // Add C/F field
      });
    });
  }

  Future<DateTime?> _selectDate() async {
    final now = DateTime.now();
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
    );
  }

  Future<void> saveChangesToFirebase() async {
    // Prepare the updated data map
    Map<String, dynamic> updatedData = {
      'Kodu': koduController.text,
      'Kalite': kaliteController.text,
      'Eni': eniController.text,
      'Gramaj': gramajController.text,
      'Supplier': supplierController.text,
      'Item No': itemNoController.text,
      'Item Name': nameController.text,
      'Price': priceController.text,
      'Date': dateController.text,
      'NOT': NOTController.text,
      'Previous_Prices': previousPrices
          .map((entry) => {
                'price': entry['price'],
                'date': entry['date'],
                'C/F': entry['C/F'], // Include C/F field
              })
          .toList(),
      if (widget.SelectedItems == 'Naylon')
        'Composition': CompositionController.text,
    };

    // Check if any changes occurred
    bool hasChanges = updatedData['Kodu'] != widget.item['Kodu'] ||
        updatedData['Kalite'] != widget.item['Kalite'] ||
        updatedData['Eni'] != widget.item['Eni'] ||
        updatedData['Gramaj'] != widget.item['Gramaj'] ||
        updatedData['Supplier'] != widget.item['Supplier'] ||
        updatedData['Item No'] != widget.item['Item No'] ||
        updatedData['Item Name'] != widget.item['Item Name'] ||
        updatedData['Price'] != widget.item['Price'] ||
        updatedData['Date'] != widget.item['Date'] ||
        updatedData['NOT'] != widget.item['NOT'] ||
        updatedData['Previous_Prices'].toString() !=
            widget.item['Previous_Prices'].toString() ||
        (widget.SelectedItems == 'Naylon' &&
            updatedData['Composition'] != widget.item['Composition']);

    if (!hasChanges) {
      // If no changes, do nothing
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes detected')),
        );
      }
      return;
    }

    try {
      // If `Kodu` changed, delete the old document and create a new one
      if (updatedData['Kodu'] != widget.item['Kodu']) {
        // Delete the old document
        await FirebaseFirestore.instance
            .collection(widget.SelectedItems)
            .doc(widget.docId)
            .delete();

        // Create a new document with the updated `Kodu` as the document ID
        await FirebaseFirestore.instance
            .collection(widget.SelectedItems)
            .doc(updatedData['Kodu'])
            .set(updatedData);
      } else {
        // If `Kodu` hasn't changed, update the existing document
        await FirebaseFirestore.instance
            .collection(widget.SelectedItems)
            .doc(widget.docId)
            .update(updatedData);
      }

      await GsheetAPI(SelectedItems: widget.SelectedItems)
          .uploadDataToGoogleSheet();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save changes: $e')),
        );
      }
    }
  }

  Widget buildTextField({
    required String prefix,
    required String suffix,
    required bool enabled,
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      keyboardType: inputType,
      obscureText: obscureText,
      decoration: InputDecoration(
        suffix: Text(suffix),
        prefix: Text('$prefix'),
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey,
        ),
        floatingLabelStyle: GoogleFonts.poppins(
          color: const Color(0xffa4392f),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xffa4392f), width: 2.0),
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
      ),
      cursorColor: const Color(0xffa4392f),
      style: GoogleFonts.poppins(color: Colors.black),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget buildEditableRow(
    String label1,
    TextEditingController controller1,
    String label2,
    TextEditingController controller2,
    String suffix1,
    String suffix2,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: buildTextField(
                  controller: controller1,
                  label: label1,
                  enabled: true,
                  suffix: suffix1,
                  prefix: ''),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildTextField(
                  controller: controller2,
                  label: label2,
                  enabled: true,
                  suffix: suffix2,
                  prefix: ''),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildEditableCard(String label, TextEditingController controller) {
    return Card(
      // color: Colors.white10,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xffa4392f),
              ),
            ),
            const SizedBox(height: 8),
            buildTextField(
                controller: controller,
                label: '',
                enabled: true,
                suffix: '',
                prefix: ''),
          ],
        ),
      ),
    );
  }

  Widget buildPreviousPricesTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Previous Prices:',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xffa4392f),
          ),
        ),
        const SizedBox(height: 10),
        Table(
          columnWidths: {
            0: FlexColumnWidth(1.5), // Price
            1: FlexColumnWidth(2.2), // Date
            2: FlexColumnWidth(1.5), // C/F
            3: FlexColumnWidth(2), // Select (Radio Button)
          },
          border: TableBorder.all(color: Colors.grey),
          children: [
            TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Price',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Date',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'C/F', // New column header for C/F
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Select',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            ...previousPrices.asMap().entries.map((entry) {
              final index = entry.key;
              final priceEntry = entry.value;

              return TableRow(
                children: [
                  TableCell(
                    child: GestureDetector(
                      onDoubleTap: () => _confirmDelete(index),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          cursorColor: const Color(0xffa4392f),
                          onChanged: (value) {
                            setState(() {
                              previousPrices[index]['price'] = value;
                            });
                          },

                          // Instead of creating a new TextEditingController on each build, set the text in the existing controller
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: previousPrices[index]['price'],
                              selection: TextSelection.collapsed(
                                  offset:
                                      previousPrices[index]['price'].length),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefix: Text("\$ "),
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Enter price',
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () async {
                          final selectedDate = await _selectDate();
                          if (selectedDate != null) {
                            setState(() {
                              previousPrices[index]['date'] =
                                  _dateFormat.format(selectedDate);
                            });
                          }
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            cursorColor: const Color(0xffa4392f),
                            controller:
                                TextEditingController(text: priceEntry['date']),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: 'Select date',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: GestureDetector(
                      onDoubleTap: () => _confirmDelete(index),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          cursorColor: const Color(0xffa4392f),
                          onChanged: (value) {
                            setState(() {
                              previousPrices[index]['C/F'] = value;
                            });
                          },
                          // Apply the same fix here for C/F
                          controller: TextEditingController.fromValue(
                            TextEditingValue(
                              text: previousPrices[index]['C/F'],
                              selection: TextSelection.collapsed(
                                  offset: previousPrices[index]['C/F'].length),
                            ),
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Enter C/F',
                          ),
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Radio<int>(
                      value: index,
                      activeColor: const Color(0xffa4392f),
                      groupValue: _selectedPriceIndex,
                      onChanged: (int? value) {
                        setState(() {
                          _selectedPriceIndex = value!;
                          priceController.text = previousPrices[index]['price'];
                          dateController.text = previousPrices[index]['date'];
                        });
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _addRow,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xffa4392f),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              'Add New Price',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void deleteItem() async {
    // If it's an existing item, delete directly from Firebase

    try {
      await FirebaseFirestore.instance
          .collection(widget.SelectedItems)
          .doc(widget.item['id'])
          .delete();
      ItemsScreenState.filteredList.removeAt(0);
      // print(widget.item);
      print(ItemsScreenState.filteredList);
    } catch (e) {
      // print('Error deleting item: $e');
      // Handle error if deletion fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await saveChangesToFirebase();
        return true; // Allows the pop to proceed after saving
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              saveChangesToFirebase();
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Edit Item',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: const Color(0xffa4392f),
          actions: [
            IconButton(
              onPressed: () async {
                deleteItem();
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              buildEditableCard('Item Name', nameController),
              const SizedBox(
                height: 10,
              ),
              buildEditableRow(
                  'Kodu', koduController, 'Kalite', kaliteController, '', ''),
              buildEditableRow('Eni', eniController, 'Gramaj', gramajController,
                  'CM', 'GSM'),
              buildEditableRow('Supplier', supplierController, 'Item No.',
                  itemNoController, '', ''),
              const SizedBox(height: 10),
              buildTextField(
                  controller: NOTController,
                  label: 'NOT',
                  enabled: true,
                  suffix: '',
                  prefix: ''),
              const SizedBox(height: 10),

              if (widget.SelectedItems == 'Naylon')
                buildTextField(
                    controller: CompositionController,
                    label: 'Composition',
                    enabled: true,
                    suffix: '',
                    prefix: ''),

              Row(
                children: [
                  Expanded(
                    child: buildTextField(
                        controller: priceController,
                        label: 'Price',
                        enabled: false,
                        suffix: '',
                        prefix: '\$ '),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AbsorbPointer(
                      child: buildTextField(
                        controller: dateController,
                        label: 'Date',
                        enabled: false,
                        suffix: '',
                        prefix: '',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              buildPreviousPricesTable(),
              const SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: saveChangesToFirebase,
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: const Color(0xffa4392f),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(16.0),
              //     ),
              //   ),
              //   child: const Padding(
              //     padding: EdgeInsets.symmetric(vertical: 12.0),
              //     child: Text(
              //       'Save Changes',
              //       style: TextStyle(color: Colors.white),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
