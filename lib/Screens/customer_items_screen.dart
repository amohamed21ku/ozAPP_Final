import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
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
          });
        });

        setState(() {
          items = fetchedItems;
          filteredItems = fetchedItems; // Initially display all items
        });
      }
    } catch (e) {
      // print('Error fetching data: $e');
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
    setState(() {
      items.add({
        'id': '',
        'kodu': '',
        'name': '',
        'date': '',
        'price': '',
        'yardage': false,
        'hanger': false,
      });
      filterData(searchController.text); // Refresh filtered items after adding
    });
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
      filterData(searchController.text); // Refresh filtered items after removal
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
    return Scaffold(
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
        title: Text(
          'Customer Items',
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xffa4392f),
      ),
      body: ModalProgressHUD(
        progressIndicator: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xffa4392f)),
          strokeWidth: 5.0,
        ),
        inAsyncCall: isLoading,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: searchController,
                onChanged: filterData,
                decoration: InputDecoration(
                  labelText: 'Search',
                  hintText: 'Search by Kodu or Name',
                  hintStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w200, fontSize: 10),
                  labelStyle:
                      GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(width: 1, color: Colors.black45),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xffa4392f), width: 2),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 10),
              ),
              const SizedBox(
                  height: 10), // Add some space between the search bar and list
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    // Use the item's 'id' field as the unique key.
                    return MyCard(
                      key: ValueKey(
                          items[index]['id']), // Unique key for each item
                      kodu: items[index]['kodu'],
                      name: items[index]['name'],
                      date: items[index]['date'],
                      price: items[index]['price'],
                      yardage: items[index]['yardage'],
                      hanger: items[index]['hanger'],
                      onChangedKodu: (value) {
                        setState(() {
                          items[index]['kodu'] = value;
                        });
                      },
                      onChangedName: (value) {
                        setState(() {
                          items[index]['name'] = value;
                        });
                      },
                      onChangedDate: (value) {
                        setState(() {
                          items[index]['date'] = value;
                        });
                      },
                      onChangedPrice: (value) {
                        setState(() {
                          items[index]['price'] = value;
                        });
                      },
                      onChangedYardage: (value) {
                        setState(() {
                          items[index]['yardage'] = value;
                        });
                      },
                      onChangedHanger: (value) {
                        setState(() {
                          items[index]['hanger'] = value;
                        });
                      },
                      onPressedDelete: () {
                        removeItem(index);
                      },
                    );
                  },
                ),
              ),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(right: 80, bottom: 4),
                      child: ElevatedButton.icon(
                        onPressed: saveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffa4392f),
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                        ),
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffa4392f),
        onPressed: addItem,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
