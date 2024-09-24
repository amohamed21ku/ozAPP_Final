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
  List<Map<String, dynamic>> filteredList = [];
  List<Map<String, dynamic>> itemsToDelete = [];
  bool isSearching = false; // Track whether the search bar is active

  TextEditingController searchController = TextEditingController();

  void _showAddItemBottomSheet(BuildContext context, String selectedItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      sheetAnimationStyle: AnimationStyle(
          duration: const Duration(
              milliseconds:
                  700)), // Allows the bottom sheet to resize when the keyboard opens
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom, // Adjust bottom padding when keyboard opens
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false, // Allow resizing of the sheet
// Maximum height when expanded
// Minimum height if dragged down
// Starts at 3/4 of the screen height

            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: SizedBox(),
                          ),
                          Expanded(
                            child: Container(
                              height: 4,
                              color: Colors.grey,
                            ),
                          ),
                          const Expanded(
                            child: SizedBox(),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
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
                            const Row(
                              children: [
                                CustomTextField(
                                  labelText: 'Kodu',
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                CustomTextField(
                                  labelText: 'Item Name',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Row(
                              children: [
                                CustomTextField(
                                  labelText: 'Kalite',
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                CustomTextField(
                                  labelText: 'Supplier',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Row(
                              children: [
                                CustomTextField(
                                  suf: Text("GSM"),
                                  labelText: 'EnI',
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                CustomTextField(
                                  suf: Text("GSM"),
                                  labelText: 'Gramaj',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            //======================
                            const Row(
                              children: [
                                CustomTextField(
                                  labelText: 'Item No.',
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                CustomTextField(
                                  labelText: 'NOT',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Row(
                              children: [
                                CustomTextField(
                                  pre: Text("\$ "),
                                  labelText: 'Price',
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                CustomTextField(
                                  labelText: 'Date',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (selectedItem == 'Naylon')
                                  const CustomTextField(
                                    labelText: 'Composition',
                                  ),
                              ],
                            ),
                            RoundedButton(
                              colour: const Color(0xffa4392f),
                              title: 'Add',
                              onPressed: () {},
                              icon: Icons.add,
                            )
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
        data['id'] = doc.id; // Add document ID to the data
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

  DateTime excelSerialDateToDateTime(int serialDate) {
    return DateTime(1899, 12, 30).add(Duration(days: serialDate));
  }

  String formatDateString(DateTime date) {
    final DateFormat formatter = DateFormat('dd-MMM-yy');
    return formatter.format(date);
  }

  Future<void> saveChangesToFirebase() async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    try {
      for (int i = 0; i < filteredList.length; i++) {
        if (filteredList[i].containsKey('isNew') && filteredList[i]['isNew']) {
          // Add new item to Firebase
          DocumentReference newDoc = FirebaseFirestore.instance
              .collection(selectedItem)
              .doc(filteredList[i]['Kodu']);
          batch.set(newDoc, {
            'Kodu': filteredList[i]['Kodu'],
            'Item Name': filteredList[i]['Item Name'],
            'Eni': filteredList[i]['Eni'],
            'Gramaj': filteredList[i]['Gramaj'],
            'Price': filteredList[i]['Price'],
            'Date': filteredList[i]['Date'],
            'Kalite': filteredList[i]['Kalite'],
            'Item No': filteredList[i]['Item No'],
            'NOT': filteredList[i]['NOT'],
            'Supplier': filteredList[i]['Supplier'],
            'Previous_Prices': filteredList[i]['Previous_Prices'],
          });

          // ];
        } else {
          // Update existing item in Firebase
          DocumentReference oldDocRef = FirebaseFirestore.instance
              .collection(selectedItem)
              .doc(filteredList[i]['documentId']);
          DocumentReference newDocRef = FirebaseFirestore.instance
              .collection(selectedItem)
              .doc(filteredList[i]['Kodu']);

          if (filteredList[i]['documentId'] != filteredList[i]['Kodu']) {
            // If Kodu has changed, copy to a new document and delete the old one
            batch.set(newDocRef, {
              'Kodu': filteredList[i]['Kodu'],
              'Item Name': filteredList[i]['Item Name'],
              'Eni': filteredList[i]['Eni'],
              'Gramaj': filteredList[i]['Gramaj'],
              'Price': filteredList[i]['Price'],
              'Date': filteredList[i]['Date'],
              'Kalite': filteredList[i]['Kalite'],
              'Item No': filteredList[i]['Item No'],
              'NOT': filteredList[i]['NOT'],
              'Supplier': filteredList[i]['Supplier'],
              'Previous_Prices': filteredList[i]['Previous_Prices'],
            });
            batch.delete(oldDocRef);

            // Update the documentId in the local list
            filteredList[i]['documentId'] = filteredList[i]['Kodu'];
          } else {
            // If Kodu has not changed, just update the existing document
            batch.update(oldDocRef, {
              'Kodu': filteredList[i]['Kodu'],
              'Item Name': filteredList[i]['Item Name'],
              'Eni': filteredList[i]['Eni'],
              'Gramaj': filteredList[i]['Gramaj'],
              'Price': filteredList[i]['Price'],
              'Date': filteredList[i]['Date'],
              'Kalite': filteredList[i]['Kalite'],
              'Item No': filteredList[i]['Item No'],
              'NOT': filteredList[i]['NOT'],
              'Supplier': filteredList[i]['Supplier'],
              'Previous_Prices': filteredList[i]['Previous_Prices'],
            });
          }
        }
      }

      for (var item in itemsToDelete) {
        DocumentReference docRef = FirebaseFirestore.instance
            .collection(selectedItem)
            .doc(item['documentId']);
        batch.delete(docRef);
      }

      itemsToDelete.clear();

      await batch.commit();
      // await fetchDataFromFirestore('items2', false);
      await saveDataToSharedPreferences();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data Saved')),
      );
    } catch (e) {
      // print('Error saving changes: $e');
    } finally {
      // setState(() => isLoading = false);
    }
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
          onPressed: () {
            // saveChangesToFirebase();
            // GsheetAPI(SelectedItems: selectedItem).uploadDataToGoogleSheet;
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
          // IconButton(
          //   onPressed: () {
          //     setState(() {
          //       edit = !edit;
          //     });
          //   },
          //   icon: Icon(
          //     edit ? Icons.edit_off : Icons.edit,
          //     color: Colors.white,
          //   ),
          // ),
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
            saveChangesToFirebase: saveChangesToFirebase,
            showColumnSelector: showColumnSelector,
          ),
          CustomItems(
            SelectedItems: selectedItem,
            isVisible: isVisible,
            searchController: searchController,
            filterData: filterData,
            saveChangesToFirebase: saveChangesToFirebase,
            showColumnSelector: showColumnSelector,
            columnOrder: columnOrder,
            columnVisibility: columnVisibility,
            filteredList: filteredList,
            edit: edit,
            deleteItem: deleteItem,
            selectDate: _selectDate,
            confirmDeleteItem: confirmDeleteItem,
            dataList: dataList,
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
