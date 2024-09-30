import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Widgets/components.dart';
import '../models/GsheetAPI.dart';
import 'TheItems.dart';

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
  static List<Map<String, dynamic>> filteredList = [];
  List<Map<String, dynamic>> itemsToDelete = [];
  bool isSearching = false; // Track whether the search bar is active

  TextEditingController searchController = TextEditingController();
  late StreamSubscription<QuerySnapshot> _firestoreSubscription;

  void _showAddItemBottomSheet(BuildContext context, String selectedItem) {
    // Create controllers for each field
    final koduController = TextEditingController();
    final itemNameController = TextEditingController();
    final kaliteController = TextEditingController();
    final supplierController = TextEditingController();
    final eniController = TextEditingController();
    final gramajController = TextEditingController();
    final itemNoController = TextEditingController();
    final notController = TextEditingController();
    final priceController = TextEditingController();
    final dateController = TextEditingController();
    final compositionController = TextEditingController();
    Future<void> _selectDate(BuildContext context) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(primary: Color(0xffa4392f)),
              buttonTheme:
                  const ButtonThemeData(textTheme: ButtonTextTheme.primary),
            ),
            child: child!,
          );
        },
      );
      if (pickedDate != null) {
        setState(() {
          dateController.text = pickedDate.toString().split(' ')[0];
        });
      }
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
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 1,
                                  child: CustomTextField(
                                    labelText: 'Item Name',
                                    controller: itemNameController,
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
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 1,
                                  child: CustomTextField(
                                    labelText: 'Supplier',
                                    controller: supplierController,
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
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 1,
                                  child: CustomTextField(
                                    suf: const Text("GSM"),
                                    labelText: 'Gramaj',
                                    controller: gramajController,
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
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 1,
                                  child: CustomTextField(
                                    labelText: 'NOT',
                                    controller: notController,
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
                                      labelText: 'Price',
                                      controller: priceController,
                                      pre: const Text("\$ ")),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () => _selectDate(
                                        context), // Trigger date picker on tap
                                    child: AbsorbPointer(
                                      child: CustomTextField(
                                        labelText: 'Date',
                                        controller: dateController,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (selectedItem == 'Naylon')
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: CustomTextField(
                                      labelText: 'Composition',
                                      controller: compositionController,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),
                            RoundedButton(
                              onPressed: () {
                                addNewItem(
                                  kodu: koduController.text,
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
      print('Error adding item to Firestore: $e');
    }
  }

  List<String> columnOrder = [
    'Kodu',
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
    _firestoreSubscription.cancel();
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
    listenToFirestoreChanges();
  }

  void listenToFirestoreChanges() {
    _firestoreSubscription = FirebaseFirestore.instance
        .collection(selectedItem)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        dataList = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['Kodu'] = doc.id;
          return data;
        }).toList();

        // Ensure dataList is sorted
        dataList.sort((a, b) => a['Kodu'].compareTo(b['Kodu']));
        filteredList = List.from(dataList);
      });
    });
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
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
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
              backgroundColor: Colors.white,
              title: Text(
                'Select Columns to Display',
                style: GoogleFonts.poppins(color: const Color(0xffa4392f)),
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
                        style: GoogleFonts.poppins(color: Colors.black),
                      ),
                      value: columnVisibility[key],
                      onChanged: (bool? value) {
                        setState(() {
                          columnVisibility[key] = value!;
                        });
                      },
                      activeColor: const Color(0xffa4392f),
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'OK',
                    style: GoogleFonts.poppins(color: const Color(0xffa4392f)),
                  ),
                  onPressed: () {
                    setState(() {
                      columnOrder = newColumnOrder;
                    });
                    saveColumnPreferences(); // Save preferences when the user confirms
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      setState(() {});
    });
  }

  Future<void> _selectDate(BuildContext context, int index) async {
    DateTime initialDate =
        DateTime.tryParse(filteredList[index]['Date']) ?? DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xffa4392f)),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        filteredList[index]['Date'] = picked.toString().split(' ')[0];
      });
    }
  }

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

  // DateTime excelSerialDateToDateTime(int serialDate) {
  //   return DateTime(1899, 12, 30).add(Duration(days: serialDate));
  // }

  String formatDateString(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MMM-yy');
    return formatter.format(date);
  }

  // Future<void> saveChangesToFirebase() async {
  //   print("fa: ${filteredList}");
  //   WriteBatch batch = FirebaseFirestore.instance.batch();
  //
  //   try {
  //     for (int i = 0; i < filteredList.length; i++) {
  //       // Update existing item in Firebase
  //       DocumentReference oldDocRef = FirebaseFirestore.instance
  //           .collection(selectedItem)
  //           .doc(filteredList[i]['documentId']);
  //       DocumentReference newDocRef = FirebaseFirestore.instance
  //           .collection(selectedItem)
  //           .doc(filteredList[i]['Kodu']);
  //
  //       if (filteredList[i]['documentId'] != filteredList[i]['Kodu']) {
  //         // If Kodu has changed, copy to a new document and delete the old one
  //         batch.set(newDocRef, {
  //           'Kodu': filteredList[i]['Kodu'],
  //           'Item Name': filteredList[i]['Item Name'],
  //           'Eni': filteredList[i]['Eni'],
  //           'Gramaj': filteredList[i]['Gramaj'],
  //           'Price': filteredList[i]['Price'],
  //           'Date': filteredList[i]['Date'],
  //           'Kalite': filteredList[i]['Kalite'],
  //           'Item No': filteredList[i]['Item No'],
  //           'NOT': filteredList[i]['NOT'],
  //           'Supplier': filteredList[i]['Supplier'],
  //           'Previous_Prices': filteredList[i]['Previous_Prices'],
  //         });
  //         batch.delete(oldDocRef);
  //
  //         // Update the documentId in the local list
  //         filteredList[i]['documentId'] = filteredList[i]['Kodu'];
  //       } else {
  //         // If Kodu has not changed, just update the existing document
  //         batch.update(oldDocRef, {
  //           'Kodu': filteredList[i]['Kodu'],
  //           'Item Name': filteredList[i]['Item Name'],
  //           'Eni': filteredList[i]['Eni'],
  //           'Gramaj': filteredList[i]['Gramaj'],
  //           'Price': filteredList[i]['Price'],
  //           'Date': filteredList[i]['Date'],
  //           'Kalite': filteredList[i]['Kalite'],
  //           'Item No': filteredList[i]['Item No'],
  //           'NOT': filteredList[i]['NOT'],
  //           'Supplier': filteredList[i]['Supplier'],
  //           'Previous_Prices': filteredList[i]['Previous_Prices'],
  //         });
  //       }
  //     }
  //
  //     for (var item in itemsToDelete) {
  //       DocumentReference docRef = FirebaseFirestore.instance
  //           .collection(selectedItem)
  //           .doc(item['documentId']);
  //       batch.delete(docRef);
  //     }
  //
  //     itemsToDelete.clear();
  //
  //     await batch.commit();
  //     await saveDataToSharedPreferences();
  //     await GsheetAPI(SelectedItems: selectedItem).uploadDataToGoogleSheet();
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Data Saved')),
  //     );
  //   } catch (e) {
  //     // print('Error saving changes: $e');
  //   } finally {
  //     // setState(() => isLoading = false);
  //   }
  // }

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
                  key: const ValueKey('searchBar'),
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search by Kodu or Name',
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
          Theitems(
            isSearching: isSearching,
            isLoading: isLoading,
            isVisible: isVisible,
            edit: edit,
            selectedItem: selectedItem,
            dataList: dataList,
            filteredList: filteredList,
            itemsToDelete: itemsToDelete,
            columnOrder: columnOrder,
            columnVisibility: columnVisibility,
            loadColumnPreferences: loadColumnPreferences,
            fetchDataForSelectedItem: fetchDataForSelectedItem,
            showColumnSelector: showColumnSelector,
          ),
          CustomItems(
            SelectedItems: selectedItem,
            isVisible: isVisible,
            searchController: searchController,
            filterData: filterData,
            showColumnSelector: showColumnSelector,
            columnOrder: columnOrder,
            columnVisibility: columnVisibility,
            filteredList: filteredList,
            edit: edit,
            deleteItem: deleteItem,
            selectDate: _selectDate,
            confirmDeleteItem: confirmDeleteItem,
            dataList: dataList,
            fetchDataForSelectedItem: fetchDataForSelectedItem,
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     _showAddItemBottomSheet(context, selectedItem);
      //   },
      // ),
    );
  }
}
