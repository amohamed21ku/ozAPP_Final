import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:oz/Screens/login_screen.dart';
import 'package:oz/Screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Widgets/buildtodo.dart';
import '../Widgets/components.dart';
import '../Widgets/calendar.dart';
import '../models/user.dart';

class HomeScreen extends StatefulWidget {
  final myUser? currentUser;

  const HomeScreen({super.key, this.currentUser});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SharedPreferences logindata;
  late String username;
  late String password;
  late String name;
  late String id;
  late String profilePicture;
  late String email;
  late myUser currentUser;
  final PageController _pageController = PageController(initialPage: 0);
  int _selectedIndex = 0;
  List<Map<String, dynamic>> events = [];
  List<bool> isCheckedList = [];
  int _backPressCounter = 0; // Counter to track back button presses

  @override
  void initState() {
    super.initState();
    initial();
    if (widget.currentUser != null) {
      currentUser = widget.currentUser!;
    } else {
      currentUser = myUser(
        username: 'default_username',
        password: 'default_password',
        name: 'Default Name',
        email: 'default@example.com',
        initial: 'D',
        id: '000',
        profilePicture:
            'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png',
        banksinfo: {},
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _refreshEvents();
    });
    if (index == 0)
      _pageController.jumpToPage(0);
    else
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 800),
        curve: Curves.ease,
      );
  }

  // Future<void> _logout(BuildContext context) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.clear(); // Clear all stored data
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => const LoginScreen()),
  //   );
  // }

  void _addEvent(String title, String description) async {
    final event = {
      'Task': title.isNotEmpty ? title : 'No Title',
      'Description': description.isNotEmpty ? description : 'No Description',
      'isChecked': false, // Default to unchecked
    };

    // Add the event to Firestore and get the document reference
    DocumentReference docRef =
        await FirebaseFirestore.instance.collection('events').add(event);

    // Add the event to the local list with the document ID
    setState(() {
      events.add({
        'docId': docRef.id,
        'title': event['Task'],
        'description': event['Description'],
        'isChecked': event['isChecked'],
      });
      isCheckedList.add(false);
    });
  }

// Delete an event
  Future<void> _deleteEventFromFirestore(int index) async {
    if (events.isEmpty || index < 0 || index >= events.length) {
      // print('Invalid index: $index. List might be empty or index out of range.');
      return;
    }

    final docId = events[index]
        ['docId']; // Assuming you've saved the docId when fetching events

    if (docId != null) {
      await FirebaseFirestore.instance.collection('events').doc(docId).delete();

      setState(() {
        events.removeAt(index);
        isCheckedList.removeAt(index);
      });
    } else {
      // print('No docId found for the event at index $index.');
    }
  }

  void _showAddEventDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController koduController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController nameController =
        TextEditingController(); // New controller

    bool isGivingSample = false;
    bool yardage = false;
    bool hanger = false;
    String selectedCustomer = '';
    String selectedCustomerId =
        ''; // To store the selected customer's document ID
    List<String> customers = []; // Will be populated from Firestore
    Map<String, String> customerIds = {}; // To map customer names to IDs

    // Fetch customers from Firestore
    Future<void> fetchCustomers() async {
      try {
        QuerySnapshot snapshot =
            await FirebaseFirestore.instance.collection('customers').get();
        customers = snapshot.docs.map((doc) => doc['name'].toString()).toList();
        customerIds = {for (var doc in snapshot.docs) doc['name']: doc.id};
      } catch (e) {
        print('Error fetching customers: $e');
      }
    }

    // Call fetchCustomers to load customer data
    fetchCustomers();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.black.withOpacity(0.65), // Make background transparent
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16.0,
                left: 16.0,
                right: 16.0,
              ),
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return ListView(
                    controller: scrollController,
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
                      SizedBox(
                        height: 6,
                      ),
                      Center(
                        child: Text(
                          'Add Task',
                          style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 18.0),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white12,
                              width: 2.0,
                            ),
                          ),
                        ),
                        dropdownColor: Colors.grey,
                        iconEnabledColor: Colors.white,
                        value: isGivingSample ? 'Giving Sample' : 'Normal Task',
                        style: GoogleFonts.poppins(color: Colors.white),
                        items: [
                          DropdownMenuItem(
                            value: 'Normal Task',
                            child: Text('Normal Task',
                                style:
                                    GoogleFonts.poppins(color: Colors.white)),
                          ),
                          DropdownMenuItem(
                            value: 'Giving Sample',
                            child: Text('Giving Sample',
                                style:
                                    GoogleFonts.poppins(color: Colors.white)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            isGivingSample = value == 'Giving Sample';
                          });
                        },
                      ),
                      if (!isGivingSample) ...[
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Task Name',
                            labelStyle:
                                GoogleFonts.poppins(color: Colors.white),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          style: GoogleFonts.poppins(color: Colors.white),
                          cursorColor: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description (optional)',
                            labelStyle:
                                GoogleFonts.poppins(color: Colors.white),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          style: GoogleFonts.poppins(color: Colors.white),
                          cursorColor: Colors.white,
                        ),
                      ] else ...[
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white12, width: 2.0),
                            ),
                          ),
                          dropdownColor: Colors.grey,
                          value: selectedCustomer.isEmpty
                              ? null
                              : selectedCustomer,
                          hint: Text('Select Customer',
                              style: GoogleFonts.poppins(color: Colors.white)),
                          items: customers.map((customer) {
                            return DropdownMenuItem(
                              value: customer,
                              child: Text(customer,
                                  style:
                                      GoogleFonts.poppins(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCustomer = value!;
                              selectedCustomerId = customerIds[value]!;
                            });
                          },
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: koduController,
                                decoration: InputDecoration(
                                  labelText: 'Kodu',
                                  labelStyle:
                                      GoogleFonts.poppins(color: Colors.white),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                style: GoogleFonts.poppins(color: Colors.white),
                                cursorColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: nameController,
                                decoration: InputDecoration(
                                  labelText: 'Name',
                                  labelStyle:
                                      GoogleFonts.poppins(color: Colors.white),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                style: GoogleFonts.poppins(color: Colors.white),
                                cursorColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: priceController,
                                decoration: InputDecoration(
                                  prefix: Text(
                                    "\$ ",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  labelText: 'Price',
                                  labelStyle:
                                      GoogleFonts.poppins(color: Colors.white),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                style: GoogleFonts.poppins(color: Colors.white),
                                cursorColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Flexible(
                              child: CheckboxListTile(
                                title: Text(
                                  'Hanger',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontSize: 16),
                                ),
                                value: hanger,
                                onChanged: (bool? value) {
                                  setState(() {
                                    hanger = value!;
                                  });
                                },
                                activeColor: Colors.white,
                                checkColor: Colors.black,
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                            Flexible(
                              child: CheckboxListTile(
                                title: Text(
                                  'Yardage',
                                  style: GoogleFonts.poppins(
                                      color: Colors.white, fontSize: 16),
                                ),
                                value: yardage,
                                onChanged: (bool? value) {
                                  setState(() {
                                    yardage = value!;
                                  });
                                },
                                activeColor: Colors.white,
                                checkColor: Colors.black,
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor:
                                    Colors.white, // Set the text color to black
                                elevation:
                                    0, // Optional: remove the shadow for a flat button look
                              ),
                              onPressed: () {
                                if (!isGivingSample) {
                                  _addEvent(
                                    titleController.text,
                                    descriptionController.text.isEmpty
                                        ? ''
                                        : descriptionController.text,
                                  );
                                } else {
                                  _addSampleEvent(
                                    selectedCustomer,
                                    koduController.text,
                                    nameController.text,
                                    priceController.text,
                                    yardage,
                                    hanger,
                                    selectedCustomerId, // Pass the customer document ID
                                  );
                                  _refreshEvents();
                                }
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Add',
                                style: GoogleFonts.poppins(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  //
  Future<void> addItemToCustomer(String docId, String name, String kodu,
      String price, bool hanger, bool yardage) async {
    try {
      // Get the current date
      DateTime now = DateTime.now();
      String formattedDate =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Reference to the specific document in the 'customers' collection
      DocumentReference customerDoc =
          FirebaseFirestore.instance.collection('customers').doc(docId);

      // Create the new item data
      Map<String, dynamic> newItem = {
        'name': name,
        'kodu': kodu,
        'price': price,
        'hanger': hanger,
        'yardage': yardage,
        'date': formattedDate,
      };

      // Update the 'items' field with the new item
      await customerDoc.update({
        'items': FieldValue.arrayUnion([newItem]),
      });

      print('Item added successfully!');
    } catch (e) {
      print('Error adding item: $e');
    }
  }

// Add Event to Firestore
  void _addSampleEvent(
    String customerName,
    String kodu,
    String name,
    String price,
    bool yardage,
    bool hanger,
    String customerId,
  ) {
    FirebaseFirestore.instance.collection('events').add({
      'Task': 'Giving Sample to $customerName',
      'Description': 'Kodu: $kodu , Price: \$$price',
      'isChecked': false,
      'Kodu': kodu,
      'Name': name,
      'Price': price,
      'Yardage': yardage,
      'Hanger': hanger,
      'CustomerId': customerId, // Store the customer document ID
    });
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();

    setState(() {
      username = logindata.getString('username') ?? '';
      password = logindata.getString('password') ?? '';
      email = logindata.getString('email') ?? '';
      name = logindata.getString('name') ?? '';
      id = logindata.getString('id') ?? '';
      profilePicture = logindata.getString('profilePic') ?? '';

      // Retrieve and decode banksinfo from SharedPreferences
      String? banksinfoString = logindata.getString('banksinfo');
      Map<String, dynamic> banksinfo = {};

      if (banksinfoString != null && banksinfoString.isNotEmpty) {
        banksinfo = Map<String, dynamic>.from(jsonDecode(banksinfoString));
      }

      // Initialize the currentUser
      currentUser = myUser(
        username: username,
        password: password,
        name: name,
        email: email,
        initial: name.isNotEmpty ? name[0].toUpperCase() : '',
        id: id,
        profilePicture: profilePicture,
        banksinfo: banksinfo,
      );
    });
    _refreshEvents();
  }

  Future<void> _fetchEvents() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('events').get();

    final fetchedEvents = querySnapshot.docs
        .map((doc) => {
              'docId': doc.id,
              'title': doc.data()['Task'] ?? 'No Title',
              'description': doc.data()['Description'] ?? 'No Description',
              'isChecked': doc.data()['isChecked'] ?? false,
              'Kodu': doc.data()['Kodu'],
              'Name': doc.data()['Name'],
              'Price': doc.data()['Price'],
              'Yardage': doc.data()['Yardage'],
              'Hanger': doc.data()['Hanger'],
              'CustomerId': doc.data()['CustomerId'],
            })
        .toList();

    setState(() {
      events = fetchedEvents;
      isCheckedList =
          List.generate(events.length, (index) => events[index]['isChecked']);
    });
  }

  Future<void> _refreshEvents() async {
    await _fetchEvents();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark); // 2
  }

  Future<bool> _onWillPop() async {
    if (_backPressCounter < 1) {
      // If the user has pressed the back button less than once
      _backPressCounter++;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false; // Prevent back navigation
    }
    return true; // Allow back navigation on the second press
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            buildHomePage(),
            buildtodo(),
            buildCalendarPage(),
            buildProfilePage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xffa4392f),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.task_alt),
              label: 'To-Do',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.today),
              label: 'Calender',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
              ),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 14),
          unselectedLabelStyle: GoogleFonts.aBeeZee(fontSize: 12),
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget buildHomePage() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: GoogleFonts.poppins(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black38,
                    ),
                  ),
                  Text(
                    currentUser.name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.black54,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  _onItemTapped(3);
                },
                child: Container(
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xffa4392f),
                      width: 3.0,
                    ),
                  ),
                  alignment: Alignment.topRight,
                  child: Hero(
                    tag: 'profile_pic',
                    child: CircleAvatar(
                      radius: 30.0,
                      backgroundImage: currentUser.profilePicture != null
                          ? CachedNetworkImageProvider(
                              currentUser.profilePicture)
                          : const AssetImage('images/man.png') as ImageProvider,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: RoundedButtonSmall(
                  colour: Colors.white,
                  title: 'Items',
                  onPressed: () {
                    Navigator.pushNamed(context, 'itemsscreen');
                  },
                  width: 10,
                  height: 100,
                  icon: Icons.list_alt,
                  iconColor: const Color(0xffa4392f),
                  textcolor: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RoundedButtonSmall(
                  colour: Colors.white,
                  title: 'Customers',
                  onPressed: () {
                    Navigator.pushNamed(context, 'customerscreen');
                  },
                  width: 0,
                  height: 100,
                  icon: Icons.person,
                  iconColor: const Color(0xffa4392f),
                  textcolor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Expanded(
                child: RoundedButtonSmall(
                  colour: Colors.white,
                  title: 'Sheet',
                  onPressed: () {
                    Navigator.pushNamed(context, "balancesheet");
                  },
                  width: 10,
                  height: 100,
                  icon: Icons.newspaper,
                  iconColor: const Color(0xffa4392f),
                  textcolor: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RoundedButtonSmall(
                  colour: Colors.white,
                  title: 'Users',
                  onPressed: () {
                    Navigator.pushNamed(context, "usersscreen");
                  },
                  width: 0,
                  height: 100,
                  icon: Icons.supervised_user_circle_outlined,
                  iconColor: const Color(0xffa4392f),
                  textcolor: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Container(height: 2, color: Colors.black26)),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
              onTap: () {
                _onItemTapped(1);
              },
              child: BuildToDo(
                events: events,
                refreshEvents: _refreshEvents,
                showAddEventDialog: _showAddEventDialog,
                deleteEventFromFirestore: _deleteEventFromFirestore,
                showadd: true,
              )),
        ],
      ),
    );
  }

  Widget buildCalendarPage() {
    return CalendarPage(currentUser: currentUser);
  }

  Widget buildProfilePage() {
    // return ProfilePage(currentUser: currentUser);
    return ProfileScreen(currentUser: currentUser);
  }

  Widget buildtodo() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:
            Text('Tasks ToDo', style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: const Color(0xffa4392f),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: _refreshEvents,
          ),
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: _showAddEventDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: BuildToDo(
          showadd: false,
          events: events,
          refreshEvents: _refreshEvents,
          showAddEventDialog: _showAddEventDialog,
          deleteEventFromFirestore: _deleteEventFromFirestore,
        ),
      ),
    );
  }
}
