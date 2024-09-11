import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
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
  List<Map<String, dynamic>> dataList = [];
  List<Map<String, dynamic>> filteredList = [];
  List<Map<String, dynamic>> itemsToDelete = [];

  TextEditingController searchController = TextEditingController();
  List<String> columnOrder = [
    'Kodu',
    'Name',
    'Eni',
    'Gramaj',
    'Price',
    'Date',
    'Supplier',
    'Kalite',
    'NOT',
    'Item No'
  ];
  Map<String, bool> columnVisibility = {
    'Kodu': true,
    'Name': true,
    'Eni': true,
    'Gramaj': true,
    'Price': true,
    'Date': false,
    'Supplier': false,
    'Kalite': false,
    'NOT': false,
    'Item No': false,
  };
  // Save column preferences to shared preferences
  Future<void> saveColumnPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('columnOrder', jsonEncode(columnOrder));
    await prefs.setString('columnVisibility', jsonEncode(columnVisibility));
  }

  // Load column preferences from shared preferences
  Future<void> loadColumnPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedOrder = prefs.getString('columnOrder');
    String? savedVisibility = prefs.getString('columnVisibility');

    if (savedOrder != null) {
      columnOrder = List<String>.from(jsonDecode(savedOrder));
    }
    if (savedVisibility != null) {
      columnVisibility = Map<String, bool>.from(jsonDecode(savedVisibility));
    }
  }

  @override
  void initState() {
    super.initState();
    loadColumnPreferences(); // Load saved preferences

    fetchDataFromCache();
    fetchDataFromFirestore(true);
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

                // Set a fixed height to avoid oversized drag targets
                child: IgnorePointer(
                  ignoring: false,
                  child: ReorderableListView(
                    physics:
                        const BouncingScrollPhysics(), // Use clamping physics to prevent bouncing
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
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
                              color: Colors.black, fontWeight: FontWeight.w400),
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
                    saveColumnPreferences(); // Save preferences when user confirms

                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      // Update the state of the ItemsScreen when the dialog is dismissed
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
            .collection('items')
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

  Future<void> fetchDataFromFirestore(bool withLoading) async {
    searchController.clear();
    setState(() => isLoading = withLoading);
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('items').get();

    dataList = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      data['id'] = doc.id; // Add the document ID to the data
      return data;
    }).toList();

    // Sort dataList based on "Kodu" field
    dataList.sort((a, b) => a['Kodu'].compareTo(b['Kodu']));

    filteredList = dataList;

    // Cache the data
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'itemsData', jsonEncode(dataList)); // Use jsonEncode here

    setState(() => isLoading = false);
  }

  Future<void> saveChangesToFirebase() async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    try {
      for (int i = 0; i < filteredList.length; i++) {
        if (filteredList[i].containsKey('isNew') && filteredList[i]['isNew']) {
          // Add new item to Firebase
          DocumentReference newDoc = FirebaseFirestore.instance
              .collection('items')
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
              .collection('items')
              .doc(filteredList[i]['documentId']);
          DocumentReference newDocRef = FirebaseFirestore.instance
              .collection('items')
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
            .collection('items')
            .doc(item['documentId']);
        batch.delete(docRef);
      }

      itemsToDelete.clear();

      await batch.commit();
      await fetchDataFromFirestore(false);
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

  void addNewItem() {
    setState(() {
      filteredList.insert(0, {
        'Kodu': '',
        'Item Name': '',
        'Eni': '',
        'Gramaj': '',
        'Price': '',
        'Date': '',
        'Supplier': '',
        'Kalite': '',
        'NOT': '',
        'Item No': '',
        'Previous_Prices': [],
        'isNew': true, // Flag to identify new items
      });
    });
  }

  void filterData(String query) {
    setState(() {
      filteredList = dataList
          .where((item) =>
              item['Kodu'].toLowerCase().contains(query.toLowerCase()) ||
              item['Item Name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
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
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xffa4392f),
        title: Text(
          'Items Screen',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                edit = !edit;
              });
            },
            icon: Icon(
              edit ? Icons.edit_off : Icons.edit,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                isVisible = !isVisible;
              });
            },
            icon: Icon(
              size: 30,
              isVisible ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xffa4392f)), // Change spinner color to theme color
              ),
            )
          : RefreshIndicator(
              onRefresh: () => fetchDataFromFirestore(true),
              color: const Color(
                  0xffa4392f), // Change refresh indicator color to theme color
              backgroundColor: Colors
                  .grey[200], // Change background color of refresh indicator
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Visibility(
                    visible: isVisible,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CustomSearchBar(
                                  searchController: searchController,
                                  onChanged: filterData,
                                  hinttext: 'Search by Kodu or Name',
                                ),
                              ),
                              const SizedBox(
                                  width:
                                      8), // Add some space between TextField and Button
                              IconButton(
                                onPressed: GsheetAPI().uploadDataToFirestore,
                                icon: const Icon(
                                  size: 25,
                                  Icons.cloud_download_rounded,
                                  color: Color(0xffa4392f),
                                ),
                              ),
                              IconButton(
                                onPressed: GsheetAPI().uploadDataToGoogleSheet,
                                icon: const Icon(
                                  size: 25,
                                  Icons.upload,
                                  color: Color(0xffa4392f),
                                ),
                              ),
                              IconButton(
                                onPressed: saveChangesToFirebase,
                                icon: const Icon(
                                  size: 25,
                                  Icons.save,
                                  color: Color(0xffa4392f),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text(
                                'Item Count: ${filteredList.length}',
                                style: GoogleFonts.poppins(
                                    color: Colors.black, fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: showColumnSelector,
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: showColumnSelector,
                                      icon: const Icon(
                                        size: 20,
                                        Icons.view_column,
                                        color: Color(0xffa4392f),
                                      ),
                                    ),
                                    Text(
                                      'Select Columns',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xffa4392f),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: const Color(0xffa4392f),
                    margin:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(isVisible ? 10.0 : 0.0),
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
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        return edit
                            ? EditCard(
                                index: index,
                                item: filteredList[index],
                                onDelete: (int index) {
                                  deleteItem(index);
                                },
                                selectDate: _selectDate,
                                confirmDeleteItem: confirmDeleteItem,
                                columnOrder: columnOrder,
                                columnVisibility: columnVisibility,
                              )
                            : GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ItemDetailsScreen(
                                        item: filteredList[index],
                                        docId: filteredList[index]['id'],
                                      ),
                                    ),
                                  ).then((_) {
                                    fetchDataFromFirestore(true);
                                  });
                                },
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        2.0), // Adjust the radius here
                                  ),
                                  color: Color(0xfffcfcfc),
                                  elevation: 2,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                    child: Row(
                                      children: columnOrder
                                          .where((column) =>
                                              columnVisibility[column]!)
                                          .map((column) {
                                        final value = filteredList[index]
                                                [column] ??
                                            filteredList[index]['Item $column'];
                                        return Expanded(
                                          child: Text(
                                            column == 'Date' && value is int
                                                ? formatDateString(
                                                    excelSerialDateToDateTime(
                                                        value))
                                                : value.toString(),
                                            style: GoogleFonts.poppins(
                                                fontSize: 12),
                                          ),
                                        );
                                      }).toList(),
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
      floatingActionButton: edit
          ? FloatingActionButton(
              onPressed: addNewItem,
              backgroundColor: const Color(0xffa4392f),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
