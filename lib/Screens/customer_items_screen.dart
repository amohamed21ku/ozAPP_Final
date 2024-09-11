import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../Widgets/components.dart';
import '../Widgets/mycard.dart';
import '../models/Customers.dart';

class CustomerItemsScreen extends StatefulWidget {
  final Customer customer;

  const CustomerItemsScreen({super.key, required this.customer});

  @override
  _CustomerItemsScreenState createState() => _CustomerItemsScreenState();
}

class _CustomerItemsScreenState extends State<CustomerItemsScreen> {
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);

    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customer.cid)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> itemsMap = data['items'] as Map<String, dynamic>;

        List<Map<String, dynamic>> fetchedItems = [];
        itemsMap.forEach((key, value) {
          fetchedItems.add({
            'id': key,
            'name': value['name'] as String,
            'kodu': value['kodu'] as String,
            'date': value['date'] as String,
            'price': value['price'] as String,
            'hanger': value['hanger'] as bool,
            'yardage': value['yardage'] as bool,
            'order': value['order'] as int, // Include the order field
          });
        });

        // Sort items by their order field
        fetchedItems
            .sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));

        setState(() {
          items = fetchedItems;
          filteredItems = fetchedItems; // Initially display all items
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
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

  void addItem() {
    // Find the current maximum order
    int maxOrder = items.isNotEmpty
        ? items
            .map((item) => item['order'] as int)
            .reduce((a, b) => a > b ? a : b)
        : 0;

    setState(() {
      items.add({
        'id': '', // Will be generated later
        'kodu': '',
        'name': '',
        'date': '',
        'price': '',
        'yardage': false,
        'hanger': false,
        'order': maxOrder + 1, // Increment order
      });
      filterData(searchController.text); // Refresh filtered items after adding
    });
    saveData();
  }

  Future<void> deleteItem(String itemId) async {
    try {
      // Fetch the current customer document
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customer.cid)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> itemsMap = data['items'] as Map<String, dynamic>;

        // Remove the item from the items map
        itemsMap.remove(itemId);

        // Update the customer document with the new items map
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(widget.customer.cid)
            .update({'items': itemsMap});
      }
    } catch (e) {
      print('Error deleting item: $e');
    }
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
      filteredItems =
          List.from(items); // Update filteredItems to reflect the change
    });
  }

  Future<void> saveData() async {
    try {
      Map<String, dynamic> updatedItems = {};
      for (var item in items) {
        String id = item['id'] as String;
        if (id.isEmpty) {
          id = FirebaseFirestore.instance.collection('customers').doc().id;
          item['id'] = id;
        }
        updatedItems[id] = {
          'name': item['name'],
          'kodu': item['kodu'],
          'date': item['date'],
          'price': item['price'],
          'hanger': item['hanger'],
          'yardage': item['yardage'],
          'order': item['order'], // Save the order
        };
      }

      await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customer.cid)
          .update({'items': updatedItems});
      // print('Data saved successfully.');
    } catch (e) {
      // print('Error saving data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await saveData();
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
              saveData();
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Customer Items',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: const Color(0xffa4392f),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: addItem,
            ),
          ],
        ),
        body: ModalProgressHUD(
          progressIndicator: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xffa4392f)),
            strokeWidth: 5.0,
          ),
          inAsyncCall: isLoading,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSearchBar(
                  searchController: searchController,
                  onChanged: filterData,
                  hinttext: 'Search by Kodu or Name',
                ),

                const SizedBox(
                    height:
                        10), // Add some space between the search bar and list
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: ValueKey(filteredItems[index]
                            ['id']), // Use item ID as the key for stability
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) async {
                          print("The deleted index is : $index");
                          print(
                              'The deleted Item is : ${filteredItems[index]}');
                          print(
                              'The deleted id is : ${filteredItems[index]['id']}');
                          // Save item ID for removal
                          String itemId = filteredItems[index]['id'];

                          // Remove the item locally first to avoid the key issue
                          setState(() {
                            filteredItems.removeAt(index);
                            items.removeWhere((item) => item['id'] == itemId);
                          });

                          // Delete the item from Firebase
                          await deleteItem(itemId);
                        },
                        confirmDismiss: (direction) async {
                          // Ask for confirmation
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  'Confirm Delete',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xffa4392f),
                                  ),
                                ),
                                content: Text(
                                  'Do you want to delete this Sample with Kodu ${filteredItems[index]['kodu']}?',
                                  style: GoogleFonts.poppins(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text(
                                      'No',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xffa4392f),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text(
                                      'Yes',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xffa4392f),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        background: Container(
                          color: Color(0xffa4392f),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: MyCard(
                          key: ValueKey(filteredItems[index]
                              ['id']), // Consistent key for MyCard
                          kodu: filteredItems[index]['kodu'],
                          name: filteredItems[index]['name'],
                          date: filteredItems[index]['date'],
                          price: filteredItems[index]['price'],
                          yardage: filteredItems[index]['yardage'],
                          hanger: filteredItems[index]['hanger'],
                          onChangedKodu: (value) {
                            setState(() {
                              filteredItems[index]['kodu'] = value;
                            });
                          },
                          onChangedName: (value) {
                            setState(() {
                              filteredItems[index]['name'] = value;
                            });
                          },
                          onChangedDate: (value) {
                            setState(() {
                              filteredItems[index]['date'] = value;
                            });
                          },
                          onChangedPrice: (value) {
                            setState(() {
                              filteredItems[index]['price'] = value;
                            });
                          },
                          onChangedYardage: (value) {
                            setState(() {
                              filteredItems[index]['yardage'] = value;
                            });
                          },
                          onChangedHanger: (value) {
                            setState(() {
                              filteredItems[index]['hanger'] = value;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                // Row(
                //   children: [
                //     Expanded(
                //       child: Container(
                //         padding: const EdgeInsets.only(right: 80, bottom: 4),
                //         child: ElevatedButton.icon(
                //           onPressed: saveData,
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: const Color(0xffa4392f),
                //             padding: const EdgeInsets.symmetric(vertical: 15.0),
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(14.0),
                //             ),
                //           ),
                //           icon: const Icon(Icons.save, color: Colors.white),
                //           label: const Text(
                //             'Save',
                //             style: TextStyle(
                //               color: Colors.white,
                //               fontSize: 16,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: const Color(0xffa4392f),
        //   onPressed: addItem,
        //   child: const Icon(Icons.add, color: Colors.white),
        // ),
      ),
    );
  }
}
