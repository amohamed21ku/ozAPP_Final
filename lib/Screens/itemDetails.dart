import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../models/GsheetAPI.dart';

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
  TextEditingController indateController = TextEditingController();
  TextEditingController NOTController = TextEditingController();
  TextEditingController CompositionController = TextEditingController();
  late Future<Map<dynamic, Map<String, dynamic>>> old_previous;

  int _selectedPriceIndex = 0; // Default to the first entry

  List<dynamic> previousPrices = [];
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy');

  void _confirmDelete(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20.0), // Rounded corners for the dialog
          ),
          backgroundColor: Colors.white, // Background color of the dialog
          title: Text(
            'Confirm Delete',
            style: GoogleFonts.poppins(
              color: const Color(0xffa4392f), // Title text color
              fontWeight: FontWeight.bold, // Bold for emphasis
            ),
          ),
          content: Text(
            'Are you sure you want to delete this entry?',
            style: GoogleFonts.poppins(
              color: Colors.black87, // Content text color
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, false), // Cancel action
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.poppins(
                      color:
                          const Color(0xffa4392f), // 'Cancel' button text color
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, true), // Delete action
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                        0xffa4392f), // 'Delete' button background color
                  ),
                  child: Text(
                    'Delete',
                    style: GoogleFonts.poppins(
                      color: Colors.white, // 'Delete' button text color
                    ),
                  ),
                ),
              ],
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
    indateController.text = widget.item['G-Tarihi'] ?? '';
    NOTController.text = widget.item['NOT'] ?? '';

    // Deep copy of Previous_Prices
    previousPrices = List<Map<String, dynamic>>.from(
      widget.item['Previous_Prices']
              ?.map((price) => Map<String, dynamic>.from(price)) ??
          [],
    );

    if (widget.SelectedItems == 'Naylon') {
      CompositionController.text = widget.item['Composition'] ?? '';
    }

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

  Future<DateTime?> _selectDate(bool isindate) async {
    final now = DateTime.now();
    DateTime initialDate;

    // Check if the indateController is empty or not
    if (isindate) {
      if (indateController.text.isEmpty) {
        initialDate = now;
      } else {
        // Parse the date from indateController, or fall back to 'now' if parsing fails
        initialDate = _dateFormat.parse(indateController.text);
      }
    } else {
      initialDate = now;
    }

    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
    );
  }

  bool comparePreviousPrices(
      List<dynamic>? sheetPrices, List<dynamic>? firestorePrices) {
    // print("Sheet price: $sheetPrices");
    // print("firestore price: $firestorePrices");
    if (sheetPrices == null || sheetPrices.isEmpty) {
      return firestorePrices == null || firestorePrices.isEmpty;
    }
    if (firestorePrices == null || firestorePrices.isEmpty) {
      return false;
    }
    if (sheetPrices.length != firestorePrices.length) {
      return false;
    }

    for (int i = 0; i < sheetPrices.length; i++) {
      final sheetPrice = sheetPrices[i];
      final firestorePrice = firestorePrices[i];
      // print("Sheet price: ${sheetPrice['C/F']}");
      // print("firestore price: ${firestorePrice['C/F']}");

      // print(sheetPrice);
      // print(firestorePrice);
      //
      // print("${sheetPrice['price']} != ${firestorePrice['price']}");
      // print("${sheetPrice['date']} != ${firestorePrice['date']}");
      // print("${sheetPrice['C/F']} != ${firestorePrice['C/F']}");

      if (sheetPrice['price'] != firestorePrice['price'] ||
          sheetPrice['date'] != firestorePrice['date'] ||
          sheetPrice['C/F'] != firestorePrice['C/F']) {
        return false;
      }
    }

    return true;
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
      'G-Tarihi': indateController.text,
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

    print(widget.item['G-Tarihi']);
    print(updatedData['G-Tarihi']);

    //
    // print(!comparePreviousPrices(
    //     updatedData['Previous_Prices'], widget.item['Previous_Prices']));
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
        updatedData['G-Tarihi'] != widget.item['G-Tarihi'] ||
        updatedData['NOT'] != widget.item['NOT'] ||
        !comparePreviousPrices(
            updatedData['Previous_Prices'], widget.item['Previous_Prices']) ||
        (widget.SelectedItems == 'Naylon' &&
            updatedData['Composition'] != widget.item['Composition']);

    if (!hasChanges) {
      // If no changes, do nothing
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('No changes detected')),
        // );
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
    required bool disabled,
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
        prefix: Text(prefix),
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey,
        ),
        floatingLabelStyle: GoogleFonts.poppins(
          color: disabled ? Colors.grey : const Color(0xffa4392f),
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
      style: GoogleFonts.poppins(color: disabled ? Colors.grey : Colors.black),
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
                  prefix: '',
                  disabled: false),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: buildTextField(
                  controller: controller2,
                  label: label2,
                  enabled: true,
                  suffix: suffix2,
                  prefix: '',
                  disabled: false),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget buildEditableCard(String label, TextEditingController controller) {
    return Card(
      color: Colors.white,
      // color: Colors.white10,
      elevation: 2,
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
                prefix: '',
                disabled: false),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Previous Prices:',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xffa4392f),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedPriceIndex = -1; // Reset the selected price index
                  priceController.clear(); // Clear the price field
                  dateController.clear(); // Clear the date field
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
                backgroundColor: Colors.white, // Text color
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Unselect Price',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(1.5), // Price
            1: FlexColumnWidth(2.5), // Date
            2: FlexColumnWidth(1.5), // C/F
            3: FlexColumnWidth(1.2), // Select (Radio Button)
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
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            prefix: Text("\$ "),
                            isDense: true,
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
                          final selectedDate = await _selectDate(false);
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
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              isDense: true,
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
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            isDense: true,
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
            }),
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
      GsheetAPI(SelectedItems: widget.SelectedItems).uploadDataToGoogleSheet();
      // print(widget.item);
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
        backgroundColor: Colors.white,
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
          title: TextField(
            controller: koduController,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter Kodu',
              hintStyle: GoogleFonts.poppins(color: Colors.white54),
            ),
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
              // buildEditableCard('Item Name', nameController),
              // const SizedBox(
              //   height: 10,
              // ),
              Row(
                children: [
                  Expanded(
                    child: buildTextField(
                      controller: nameController,
                      label: 'Item name',
                      enabled: true,
                      suffix: '',
                      prefix: '',
                      disabled: false,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final selecteddate = await _selectDate(true);
                        if (selecteddate != null) {
                          indateController.text =
                              _dateFormat.format(selecteddate);
                        }
                      },
                      child: AbsorbPointer(
                        child: buildTextField(
                          controller: indateController,
                          label: 'Giriş  Tarihi',
                          enabled: true,
                          suffix: '',
                          prefix: '',
                          disabled: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // buildEditableRow(
              //     'Kodu', koduController, 'Kalite', kaliteController, '', ''),
              buildEditableRow('Eni', eniController, 'Gramaj', gramajController,
                  'CM', 'GSM'),
              buildEditableRow('Supplier', supplierController, 'Item No.',
                  itemNoController, '', ''),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: buildTextField(
                      controller: kaliteController,
                      label: 'Kalitle',
                      enabled: true,
                      suffix: '',
                      prefix: '',
                      disabled: false,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: buildTextField(
                        controller: NOTController,
                        label: 'NOT',
                        enabled: true,
                        suffix: '',
                        prefix: '',
                        disabled: false),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (widget.SelectedItems == 'Naylon')
                buildTextField(
                    controller: CompositionController,
                    label: 'Composition',
                    enabled: true,
                    suffix: '',
                    prefix: '',
                    disabled: false),
              // const SizedBox(height: 10),
              // Row(
              //   children: [
              //     Expanded(
              //       child: AbsorbPointer(
              //         child: buildTextField(
              //             controller: priceController,
              //             label: 'Price',
              //             enabled: true,
              //             suffix: '',
              //             prefix: '\$ ',
              //             disabled: true),
              //       ),
              //     ),
              //     const SizedBox(width: 10),
              //     Expanded(
              //       child: AbsorbPointer(
              //         child: buildTextField(
              //           controller: dateController,
              //           label: 'Date',
              //           enabled: true,
              //           suffix: '',
              //           prefix: '',
              //           disabled: true,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(
              //   height: 10,
              // ),
              buildPreviousPricesTable(),
            ],
          ),
        ),
      ),
    );
  }
}
