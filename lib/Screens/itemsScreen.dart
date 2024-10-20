import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:oz/models/GsheetAPI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Widgets/components.dart';
import '../Widgets/mycard.dart';
import 'itemDetails.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  ItemsScreenState createState() => ItemsScreenState();
}

class ItemsScreenState extends State<ItemsScreen> {
  bool isLoading = false;
  bool isVisible = true;
  bool edit = false;
  String selectedItem = 'Polyester';

  List<Map<String, dynamic>> dataList = [];
  List<Map<String, dynamic>> filteredList = [];
  int ItemCount = 0;

  List<Map<String, dynamic>> itemsToDelete = [];
  bool isSearching = false; // Track whether the search bar is active

  TextEditingController searchController = TextEditingController();

  void _showAddItemBottomSheet(BuildContext context, String selectedItem) {
    // Create controllers for each field
    final DateFormat _dateFormat = DateFormat('MMM d, yyyy');

    final koduController = TextEditingController();
    koduController.text = "${dataList.length + 1}";
    final itemNameController = TextEditingController();
    final kaliteController = TextEditingController();
    final supplierController = TextEditingController();
    final eniController = TextEditingController();
    final gramajController = TextEditingController();
    final itemNoController = TextEditingController();
    final notController = TextEditingController();
    final priceController = TextEditingController();
    final dateController = TextEditingController();
    final indateController = TextEditingController(
      text: _dateFormat.format(DateTime.now()), // Initialize with today's date
    );

    final compositionController = TextEditingController();

    Future<DateTime?> _selectDate() async {
      final now = DateTime.now();

      DateTime initialDate;
      if (indateController.text.isEmpty) {
        initialDate = now;
      } else {
        initialDate = _dateFormat.parse(indateController.text);
      }

      // Check if the indateController is empty or not

      return await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(now.year + 1),
      );
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      sheetAnimationStyle:
          AnimationStyle(duration: const Duration(milliseconds: 700)),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Expanded(flex: 1, child: SizedBox()),
                          Expanded(
                              child: Container(
                            height: 4,
                            color: Colors.grey,
                          )),
                          const Expanded(child: SizedBox())
                        ],
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        'Add New Item',
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
                                  flex: 1,
                                  child: CustomTextField(
                                    labelText: 'Kodu',
                                    controller: koduController,
                                    enabled: true,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () async {
                                      final selectedDate = await _selectDate();
                                      if (selectedDate != null) {
                                        setState(() {
                                          indateController.text =
                                              _dateFormat.format(selectedDate);
                                        });
                                      }
                                    },
                                    child: AbsorbPointer(
                                      child: CustomTextField(
                                        labelText: 'Giriş Tarihi',
                                        controller: indateController,
                                        enabled: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: CustomTextField(
                                    labelText: 'Kalite',
                                    controller: kaliteController,
                                    enabled: true,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 1,
                                  child: CustomTextField(
                                    labelText: 'Supplier',
                                    controller: supplierController,
                                    enabled: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: CustomTextField(
                                    labelText: 'Eni',
                                    suf: const Text("CM"),
                                    controller: eniController,
                                    enabled: true,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 1,
                                  child: CustomTextField(
                                    suf: const Text("GSM"),
                                    labelText: 'Gramaj',
                                    controller: gramajController,
                                    enabled: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: CustomTextField(
                                    labelText: 'Item No.',
                                    controller: itemNoController,
                                    enabled: true,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 1,
                                  child: CustomTextField(
                                    labelText: 'Item Name',
                                    controller: itemNameController,
                                    enabled: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: CustomTextField(
                                    labelText: 'NOT',
                                    controller: notController,
                                    enabled: true,
                                  ),
                                ),
                              ],
                            ),
                            // Row(
                            //   children: [
                            //     Expanded(
                            //       flex: 1,
                            //       child: CustomTextField(
                            //           labelText: 'Price',
                            //           controller: priceController,
                            //           pre: const Text("\$ ")),
                            //     ),
                            //     const SizedBox(width: 5),
                            //     Expanded(
                            //       flex: 1,
                            //       child: GestureDetector(
                            //         onTap: () => _selectDate(
                            //             context), // Trigger date picker on tap
                            //         child: AbsorbPointer(
                            //           child: CustomTextField(
                            //             labelText: 'Date',
                            //             controller: dateController,
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // const SizedBox(height: 16),
                            if (selectedItem == 'Naylon')
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: CustomTextField(
                                      labelText: 'Composition',
                                      controller: compositionController,
                                      enabled: true,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),
                            RoundedButton(
                              onPressed: () {
                                setState(() {
                                  isSearching = false;
                                  searchController.clear();
                                });
                                // searchController.dispose();
                                addNewItem(
                                  kodu: koduController.text,
                                  G_Tarihi: indateController.text,
                                  itemName: itemNameController.text,
                                  kalite: kaliteController.text,
                                  supplier: supplierController.text,
                                  eni: eniController.text,
                                  gramaj: gramajController.text,
                                  itemNo: itemNoController.text,
                                  not: notController.text,
                                  price: priceController.text,
                                  date: dateController.text,
                                  composition: selectedItem == 'Naylon'
                                      ? compositionController.text
                                      : '',
                                );

                                GsheetAPI(SelectedItems: selectedItem)
                                    .uploadDataToGoogleSheet();
                                fetchDataForSelectedItem();
                                Navigator.pop(
                                    context); // Close the bottom sheet
                              },
                              colour: const Color(0xffa4392f),
                              title: 'Add',
                              icon: Icons.add,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void addNewItem({
    required String kodu,
    required String G_Tarihi,
    required String itemName,
    required String kalite,
    required String supplier,
    required String eni,
    required String gramaj,
    required String itemNo,
    required String not,
    required String price,
    required String date,
    required String composition,
  }) async {
    // Create a map for the new item

    final newItem = {
      'Kodu': kodu,
      'G-Tarihi': G_Tarihi,
      'Item Name': itemName,
      'Eni': eni,
      'Gramaj': gramaj,
      'Price': price,
      'Date': date,
      'Supplier': supplier,
      'Kalite': kalite,
      'NOT': not,
      'Item No': itemNo,

      'Previous_Prices': [],
      if (selectedItem == 'Naylon') 'Composition': composition,
      // 'isNew': true, // Flag to identify new items
    };

    try {
      // Add the new item to the Firestore collection for SelectedItems
      await FirebaseFirestore.instance
          .collection(selectedItem)
          .doc(kodu) // Replace with your actual collection name
          .set(newItem);

      // Optionally, you can update the local filteredList or manage state here if needed
      setState(() {
        filteredList.insert(
            0, newItem); // If you want to keep local state in sync
      });
    } catch (e) {
      // Handle any errors here
      // print('Error adding item to Firestore: $e');
    }
  }

  List<String> columnOrder = [
    'Kodu',
    'G-Tarihi',
    'Name',
    'Eni',
    'Gramaj',
    'Composition',
    'Price',
    'Date',
    'Supplier',
    'Kalite',
    'NOT',
    'Item No',
  ];
  Map<String, bool> columnVisibility = {
    'Kodu': true,
    'G-Tarihi': true,
    'Name': true,
    'Eni': true,
    'Gramaj': true,
    'Composition': false,
    'Price': true,
    'Date': false,
    'Supplier': false,
    'Kalite': false,
    'NOT': false,
    'Item No': false,
  };

  Future<void> saveColumnPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Save column order and visibility based on the selected item
    String keyOrder = '${selectedItem}_columnOrder';
    String keyVisibility = '${selectedItem}_columnVisibility';

    await prefs.setString(keyOrder, jsonEncode(columnOrder));
    await prefs.setString(keyVisibility, jsonEncode(columnVisibility));
  }

  Future<void> loadColumnPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String keyOrder = '${selectedItem}_columnOrder';
    String keyVisibility = '${selectedItem}_columnVisibility';

    String? savedOrder = prefs.getString(keyOrder);
    String? savedVisibility = prefs.getString(keyVisibility);

    // Load preferences for the selected item
    if (savedOrder != null) {
      setState(() {
        columnOrder = List<String>.from(jsonDecode(savedOrder));
      });
    }
    if (savedVisibility != null) {
      setState(() {
        columnVisibility = Map<String, bool>.from(jsonDecode(savedVisibility));
      });
    }
  }

  @override
  void dispose() {
    // Cancel the Firestore listener when the widget is disposed
    searchController.dispose();
    super.dispose();
  }

  // String collection = 'items';
  @override
  void initState() {
    super.initState();

    loadColumnPreferences();
    fetchDataFromCache();
    // Listen to changes in the search input
    searchController.addListener(() {
      filterData(searchController.text);
    });

    // Start listening to Firestore changes
    // listenToFirestoreChanges();
    fetchDataForSelectedItem();
  }

  Future<void> fetchDataForSelectedItem() async {
    setState(() {
      isLoading = true;
      filteredList = []; // Clear the current list to avoid confusion
    });

    // Fetch data from Firebase for the selected item
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection(selectedItem).get();

      dataList = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['Kodu'] = doc.id; // Add document ID to the data
        return data;
      }).toList();

      // Ensure dataList is sorted
      dataList.sort((a, b) => a['Kodu'].compareTo(b['Kodu']));

      setState(() {
        filteredList = List.from(dataList); // Update the filtered list
        isLoading = false;
        ItemCount = isSearching ? filteredList.length : dataList.length;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // print('Error fetching data: $e');
    }
  }

  void showColumnSelector() {
    List<String> newColumnOrder = List.from(columnOrder);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0), // Rounded corners
              ),
              backgroundColor: Colors.white, // Background color
              title: Text(
                'Select Columns to Display',
                style: GoogleFonts.poppins(
                  color: const Color(0xffa4392f), // Title color
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ReorderableListView(
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final String item = newColumnOrder.removeAt(oldIndex);
                      newColumnOrder.insert(newIndex, item);
                    });
                  },
                  children: newColumnOrder.map((String key) {
                    return CheckboxListTile(
                      key: Key(key),
                      title: Text(
                        key,
                        style: GoogleFonts.poppins(
                            color: Colors.black), // Checkbox title color
                      ),
                      value: columnVisibility[key],
                      onChanged: (bool? value) {
                        setState(() {
                          columnVisibility[key] = value!; // Update visibility
                        });
                      },
                      activeColor:
                          const Color(0xffa4392f), // Checkbox active color
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: GoogleFonts.poppins(
                      color: const Color(0xffa4392f), // OK button color
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      columnOrder = newColumnOrder; // Update column order
                    });
                    saveColumnPreferences(); // Save preferences
                    Navigator.of(context).pop(); // Close dialog
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      setState(() {}); // Refresh state after dialog closes
    });
  }

  // Future<void> _selectDate(BuildContext context, int index) async {
  //   DateTime initialDate =
  //       DateTime.tryParse(filteredList[index]['Date']) ?? DateTime.now();
  //   DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: initialDate,
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //     builder: (BuildContext context, Widget? child) {
  //       return Theme(
  //         data: ThemeData.light().copyWith(
  //           colorScheme: const ColorScheme.light(primary: Color(0xffa4392f)),
  //           buttonTheme:
  //               const ButtonThemeData(textTheme: ButtonTextTheme.primary),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       filteredList[index]['Date'] = picked.toString().split(' ')[0];
  //     });
  //   }
  // }

  Future<bool?> confirmDeleteItem(int index) async {
    return await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Delete Item",
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          content: Text(
            "Are you sure you want to delete the item with code ${filteredList[index]['Kodu']}?",
            style: GoogleFonts.poppins(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: const Color(0xffa4392f)),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                "Delete",
                style: GoogleFonts.poppins(color: const Color(0xffa4392f)),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
                deleteItem(index);
              },
            ),
          ],
        );
      },
    );
  }

  void deleteItem(int index) async {
    // If it's an existing item, delete directly from Firebase
    if (!filteredList[index].containsKey('isNew')) {
      try {
        await FirebaseFirestore.instance
            .collection(selectedItem)
            .doc(filteredList[index]['id'])
            .delete();
      } catch (e) {
        // print('Error deleting item: $e');
        // Handle error if deletion fails
      }
    }
    setState(() {
      filteredList.removeAt(index);
    });
  }

  String formatDateString(DateTime date) {
    final DateFormat formatter = DateFormat('MMM d, yyyy');
    return formatter.format(date);
  }

  Future<void> saveDataToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('dataList', json.encode(dataList));
    await prefs.setString('filteredList', json.encode(filteredList));
  }

  Future<void> fetchDataFromCache() async {
    searchController.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('itemsData');
    if (cachedData != null) {
      dataList = List<Map<String, dynamic>>.from(
        jsonDecode(cachedData).map((item) => Map<String, dynamic>.from(item)),
      );
      setState(() => filteredList = dataList);
    }
  }

  // This function filters the data based on the search query
  void filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredList = List.from(dataList); // Show all items if no search query
      } else {
        filteredList = dataList
            .where((item) =>
                item['Kodu'].toLowerCase().contains(query.toLowerCase()) ||
                item['Kalite'].toLowerCase().contains(query.toLowerCase()) ||
                item['Item No'].toLowerCase().contains(query.toLowerCase()) ||
                item['Item Name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
          onPressed: () async {
            // Save changes to Firebase
            // saveChangesToFirebase();

            // Close the dialog or perform any other actions
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xffa4392f),
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isSearching
              ? TextField(
                  cursorColor: Colors.white,
                  key: const ValueKey('searchBar'),
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search for Item',
                    border: InputBorder.none,
                    hintStyle: GoogleFonts.poppins(color: Colors.white),
                  ),
                  style: GoogleFonts.poppins(color: Colors.white),
                )
              : DropdownButton<String>(
                  key: const ValueKey('dropdownMenu'),
                  value: selectedItem,
                  dropdownColor: const Color(0xffa4392f),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
                  underline: Container(), // Hide underline
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  items: <String>['Polyester', 'Naylon'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedItem = newValue!;
                      loadColumnPreferences(); // Load the correct preferences when switching items
                      fetchDataForSelectedItem(); // Fetch new data based on the selected item
                    });
                  },
                ),
        ),
        actions: [
          if (!isSearching)
            IconButton(
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  isSearching = true;
                });
              },
            ),
          if (isSearching)
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  isSearching = false;
                  searchController.clear();
                });
              },
            ),
          IconButton(
            onPressed: () {
              _showAddItemBottomSheet(context, selectedItem);
            },
            icon: const Icon(
              size: 30,
              Icons.add_box_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Column(
            children: [
              // Replace VisibleActions with the new custom widget logic
              if (!isVisible)
                const SizedBox
                    .shrink() // Return an empty widget when not visible
              else
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            // Add the button here
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.numbers),
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  'Item Count: $ItemCount',
                                  style: GoogleFonts.poppins(
                                      color: Colors.black, fontSize: 14),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () {
                                      GsheetAPI(SelectedItems: selectedItem)
                                          .ConfirmingGetFromGoogleSheet(
                                              context);
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor:
                                          Colors.white, // Text color
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12.0),
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.cloud_download_rounded),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'Get From Excel',
                                            style: GoogleFonts.poppins(
                                                color: Colors.black),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: showColumnSelector,
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.white, // Text color
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.list_alt),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          'Select Columns',
                                          style: GoogleFonts.poppins(
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              GestureDetector(
                onVerticalDragUpdate: (details) {
                  if (details.primaryDelta! < 0) {
                    // Dragging upwards
                    setState(() {
                      isVisible = false;
                    });
                  } else if (details.primaryDelta! > 0) {
                    // Dragging downwards
                    setState(() {
                      isVisible = true;
                    });
                  }
                },
                child: Card(
                  color: const Color(0xffa4392f),
                  margin:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isVisible ? 10.0 : 0.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                    child: Row(
                      children: columnOrder
                          .where((column) => columnVisibility[column]!)
                          .map((column) => Expanded(
                                child: Text(
                                  column,
                                  style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          )
          // Theitems(
          //   isSearching: isSearching,
          //   isLoading: isLoading,
          //   isVisible: isVisible,
          //   edit: edit,
          //   selectedItem: selectedItem,
          //   dataList: dataList,
          //   filteredList: filteredList,
          //   itemsToDelete: itemsToDelete,
          //   columnOrder: columnOrder,
          //   columnVisibility: columnVisibility,
          //   loadColumnPreferences: loadColumnPreferences,
          //   fetchDataForSelectedItem: fetchDataForSelectedItem,
          //   showColumnSelector: showColumnSelector,
          //   ItemCount: ItemCount,
          // ),

          ,
          Expanded(
            // This ensures the StreamBuilder takes up the remaining space
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(selectedItem)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xffa4392f)),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Update dataList with live data from Firestore
                dataList = snapshot.data!.docs.map((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  data['id'] = doc.id; // Add document ID to the data
                  return data;
                }).toList();

                // Ensure dataList is sorted
                dataList.sort((a, b) => a['Kodu'].compareTo(b['Kodu']));

                // Only update filteredList if the search query is empty, otherwise keep the filtered items
                if (searchController.text.isEmpty) {
                  filteredList = List.from(dataList);
                }

                // Now return the UI with the filtered list
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ItemDetailsScreen(
                                            index: index,
                                            SelectedItems: selectedItem,
                                            item: filteredList[index],
                                            docId: filteredList[index]['id'],
                                          )),
                                ).then((_) {
                                  fetchDataForSelectedItem;
                                });
                              },
                              child: ItemCard(
                                Item: filteredList[index],
                                columnOrder: columnOrder,
                                columnVisibility: columnVisibility,
                                index: index,
                              ));
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
