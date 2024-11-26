import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_screen.dart'; // For the detailed item view

class CustomerListScreen extends StatefulWidget {
  final String customerName;
  final String customerId;

  const CustomerListScreen({
    super.key,
    required this.customerName,
    required this.customerId,
  });

  @override
  _CustomerListScreenState createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  bool isSearching = false; // Flag to toggle search mode

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customerId)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Map<String, dynamic> itemsMap = data['items'] ?? {};

        List<Map<String, dynamic>> fetchedItems = itemsMap.entries.map((entry) {
          final item = entry.value as Map<String, dynamic>;
          return {
            'id': entry.key,
            ...item,
          };
        }).toList()
          ..sort((a, b) => (a['order'] ?? 0).compareTo(b['order'] ?? 0));

        setState(() {
          items = fetchedItems;
          filteredItems = fetchedItems;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void filterData(String query) {
    setState(() {
      filteredItems = items
          .where((item) =>
              item['kodu'].toLowerCase().contains(query.toLowerCase()) ||
              item['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void toggleSearch() {
    setState(() {
      isSearching = !isSearching;
      if (!isSearching) {
        searchController.clear();
        filterData(''); // Reset the filtered list when exiting search
      }
    });
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customerId)
          .update({
        'items.$itemId': FieldValue.delete(),
      });
      // Refresh the list after deletion
      await fetchData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully.')),
      );
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  void openAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      sheetAnimationStyle:
          AnimationStyle(duration: const Duration(milliseconds: 700)),
      builder: (context) => AddItemSheet(
        customerId: widget.customerId,
        onItemAdded: fetchData, // Refresh data after adding a new item
      ),
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
                widget.customerName,
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
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
              Icons.add_box,
              size: 30,
              color: Colors.white,
            ),
            onPressed: openAddItemSheet,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return Dismissible(
                          key: Key(item['id']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: const Color(0xffa4392f),
                            alignment: Alignment.centerRight,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) async {
                            await deleteItem(item['id']);
                          },
                          child: Card(
                            elevation:
                                2, // Reduce elevation for a subtler shadow
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8), // Minimize spacing
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // Slightly rounded corners
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                  8), // Match the card's shape
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailScreen(
                                      customerId: widget.customerId,
                                      itemId: item['id'],
                                      itemData: item,
                                    ),
                                  ),
                                ).then((_) {
                                  fetchData(); // Reload data after returning
                                });
                              },
                              child: Container(
                                height: 80, // Fixed height for all cards
                                padding:
                                    const EdgeInsets.all(8), // Reduced padding
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.circle,
                                      color: Color(0xffa4392f),
                                      size: 15,
                                    ),
                                    // Leading section (e.g., icon or image)
                                    // CircleAvatar(
                                    //   radius: 25,
                                    //   backgroundColor: const Color(0xffa4392f),
                                    //   child: Text(
                                    //     '${item['kodu'].substring(0, 3)}', // Display first letter of 'kodu'
                                    //     style: GoogleFonts.poppins(
                                    //       fontSize: 15,
                                    //       fontWeight: FontWeight.bold,
                                    //       color: Colors.white,
                                    //     ),
                                    //   ),
                                    // ),
                                    const SizedBox(
                                        width:
                                            12), // Space between avatar and text
                                    // Text content
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${item['kodu']} - ${item['name']}',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow
                                                .ellipsis, // Truncate long text
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Price: ${item['price']} | Date: ${item['date']}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Optional trailing icon or action
                                    const Icon(Icons.arrow_forward_ios,
                                        size: 16, color: Colors.grey),
                                  ],
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

// The AddItemSheet remains the same from the original code above

class AddItemSheet extends StatefulWidget {
  final String customerId;
  final VoidCallback onItemAdded;

  const AddItemSheet({
    Key? key,
    required this.customerId,
    required this.onItemAdded,
  }) : super(key: key);

  @override
  _AddItemSheetState createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  TextEditingController koduController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController notController = TextEditingController();
  bool yardage = false;
  bool hanger = false;
  bool ld = false;

  @override
  void initState() {
    super.initState();
    // Set the default date to today's date
    dateController.text = DateTime.now().toString().split(' ')[0];
  }

  // Fetch item name based on the 'kodu' entered
  Future<void> fetchNameByKodu(String kodu) async {
    if (kodu.isEmpty) return;

    try {
      // Query the Firestore collection (assuming 'Polyester' collection)
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Polyester')
          .doc(kodu)
          .get();

      if (doc.exists) {
        setState(() {
          nameController.text = doc['Kalite'] ?? ''; // Auto-fill name if found
        });
      } else {
        // print("not exist");
        setState(() {
          nameController.clear(); // Clear name if no match found
        });
      }
    } catch (e) {
      print('Error fetching name by kodu: $e');
    }
  }

  Future<void> saveData() async {
    try {
      // Fetch the current document to determine the next order
      DocumentSnapshot customerDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customerId)
          .get();

      Map<String, dynamic> currentData =
          customerDoc.data() as Map<String, dynamic>;
      Map<String, dynamic> currentItems = currentData['items'] ?? {};

      // Determine the next order based on existing items
      int nextOrder = currentItems.values
              .map((item) => item['order'] ?? 0)
              .toList()
              .cast<int>()
              .fold(0, (prev, curr) => curr > prev ? curr : prev) +
          1;

      String newItemId =
          FirebaseFirestore.instance.collection('customers').doc().id;

      // New item structure
      Map<String, dynamic> newItem = {
        'name': nameController.text,
        'kodu': koduController.text,
        'date': dateController.text,
        'price': priceController.text,
        'hanger': hanger,
        'yardage': yardage,
        'ld': ld,
        'not': notController.text,
        'order': nextOrder, // Assign the next order
      };

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customerId)
          .update({
        'items.$newItemId': newItem, // Add new item as a nested map
      });

      print('Item added successfully.');

      // Call the callback to refresh the list
      widget.onItemAdded();

      Navigator.pop(context); // Close the bottom sheet
    } catch (e) {
      print('Error saving item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Drag indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add New Sample',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffa4392f),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildCustomTextField(
                                controller: koduController,
                                label: 'Kodu',
                                onChanged: fetchNameByKodu, // Auto-fetch name
                              ),
                            ),
                            Expanded(
                              child: _buildCustomTextField(
                                controller: nameController,
                                label: 'Kalite',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final selectedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                  );
                                  if (selectedDate != null) {
                                    dateController.text =
                                        selectedDate.toString().split(' ')[0];
                                  }
                                },
                                child: AbsorbPointer(
                                  child: _buildCustomTextField(
                                    controller: dateController,
                                    label: 'Date',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildCustomTextField(
                                controller: priceController,
                                label: 'Price',
                                prefixText: '\$ ',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCustomTextField(
                          controller: notController,
                          label: 'Note',
                          maxLines: 4,
                          isNoteField: true,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildCheckbox(
                                label: 'Yardage',
                                value: yardage,
                                onChanged: (val) {
                                  setState(() {
                                    yardage = val;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: _buildCheckbox(
                                label: 'Hanger',
                                value: hanger,
                                onChanged: (val) {
                                  setState(() {
                                    hanger = val;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: _buildCheckbox(
                                label: 'L/D',
                                value: ld,
                                onChanged: (val) {
                                  setState(() {
                                    ld = val;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffa4392f),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(
                      'Add',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Helpers (from original code)
Widget _buildCheckbox({
  required String label,
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return Row(
    children: [
      Text(label, style: GoogleFonts.poppins(fontSize: 14)),
      Checkbox(
        value: value,
        onChanged: (val) {
          if (val != null) {
            onChanged(val);
          }
        },
        activeColor: const Color(0xffa4392f),
      ),
    ],
  );
}

Widget _buildCustomTextField({
  required TextEditingController controller,
  required String label,
  String? prefixText,
  int? maxLines, // Optional maxLines parameter for flexibility
  bool isNoteField = false, // Distinguish Note UI
  Function(String)? onChanged, // Add this line for onChanged
}) {
  return TextField(
    controller: controller,
    maxLines: isNoteField ? (maxLines ?? 4) : maxLines ?? 1,
    onChanged: onChanged, // Pass the onChanged function to TextField
    decoration: InputDecoration(
      labelText: label,
      prefixText: prefixText,
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: const Color(0xffa4392f),
      ),
      focusedBorder: isNoteField
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xffa4392f)),
            )
          : const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffa4392f)),
            ),
      enabledBorder: isNoteField
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xffa4392f)),
            )
          : null,
      filled: isNoteField,
      fillColor: isNoteField ? const Color(0xfff2e9e9) : null, // Darker shade
      contentPadding: isNoteField
          ? const EdgeInsets.symmetric(vertical: 15, horizontal: 15)
          : null,
    ),
    cursorColor: const Color(0xffa4392f),
    style: GoogleFonts.poppins(
      fontSize: 14,
    ),
  );
}
