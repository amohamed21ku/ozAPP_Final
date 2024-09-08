import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:oz/Screens/login_screen.dart';
import 'package:oz/Screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Widgets/components.dart';
import '../Widgets/todo.dart';
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
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _refreshEvents();

      if (index == 0) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark); // 1
      }
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 700),
      curve: Curves.ease,
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

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

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20.0), // Adjust the corner radius
            side: const BorderSide(
              color: Colors.grey, // Border color
              width: 2.0, // Border width
            ),
          ),
          backgroundColor: const Color(0xffa4392f),
          title: Text(
            'Add Task',
            style: GoogleFonts.poppins(color: Colors.white), // Title text color
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  labelStyle: GoogleFonts.poppins(
                      color: Colors.white), // Title text color
                  // Input label text color
                  enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white), // Input border color
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white), // Focused input border color
                  ),
                ),
                style: GoogleFonts.poppins(color: Colors.white),
                cursorColor: Colors.white, // Input text color
              ),
              const SizedBox(height: 20),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  labelStyle: GoogleFonts.poppins(
                      color: Colors.white), // Title text color
                  // Input label text color
                  enabledBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white), // Input border color
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.white), // Focused input border color
                  ),
                ),
                style: GoogleFonts.poppins(color: Colors.white),
                cursorColor: Colors.white, // Input text color
              ),
            ],
          ),
          actions: [
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
                      style: GoogleFonts.poppins(
                          color: Colors.white), // Title text color
                      // Button text color
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _addEvent(
                          titleController.text,
                          descriptionController.text.isEmpty
                              ? ''
                              : descriptionController.text);
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
    );
  }

  void initial() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      username = logindata.getString('username')!;
      password = logindata.getString('password')!;
      email = logindata.getString('email')!;
      name = logindata.getString('name')!;
      id = logindata.getString('id')!;
      profilePicture = logindata.getString('profilePic')!;

      currentUser = myUser(
        username: username,
        password: password,
        name: name,
        email: email,
        initial: name[0],
        id: id,
        profilePicture: profilePicture,
      );
    });

    await _fetchEvents();
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
            buildToDoPage(),
            buildProfilePage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xffa4392f),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.today),
              label: 'ToDo',
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

    return Container(
      color: Colors.white,
      // padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
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
                    _onItemTapped(2);
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
                                currentUser.profilePicture!)
                            : const AssetImage('images/man.png')
                                as ImageProvider,
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
            Card(
              color: const Color(0xbba4392f),
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Today\'s Tasks',
                              style: GoogleFonts.poppins(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: _refreshEvents,
                                    icon: const Icon(
                                      size: 25,
                                      Icons.refresh,
                                      color: Colors.white,
                                    )),
                                IconButton(
                                  onPressed: _showAddEventDialog,
                                  icon: const Icon(
                                    size: 25,
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const BouncingScrollPhysics(), // You can choose different scroll physics
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];

                        // Ensure timestampString is not null before parsing

                        return Dismissible(
                          direction:
                              DismissDirection.startToEnd, // Swipe direction

                          key: UniqueKey(),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    'Confirm Delete',
                                    style: GoogleFonts.poppins(
                                      color: const Color(
                                          0xffa4392f), // Specify the color
                                    ),
                                  ),
                                  content: Text(
                                    'Do you want to delete this Task?',
                                    style: GoogleFonts
                                        .poppins(), // Use default Poppins style
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(false); // Cancel deletion
                                      },
                                      child: Text(
                                        'No',
                                        style: GoogleFonts.poppins(
                                          color: const Color(
                                              0xffa4392f), // Specify the color
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(true); // Confirm deletion
                                      },
                                      child: Text(
                                        'Yes',
                                        style: GoogleFonts.poppins(
                                          color: const Color(
                                              0xffa4392f), // Specify the color
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          background: Container(
                            color: Colors.white70,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) async {
                            await _deleteEventFromFirestore(index);
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12.0,
                                horizontal: 15.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final docId = event['docId'];

                                      if (docId != null) {
                                        final docRef = FirebaseFirestore
                                            .instance
                                            .collection('events')
                                            .doc(docId);

                                        try {
                                          // Toggle the 'isChecked' value in Firestore
                                          await docRef.update({
                                            'isChecked': !event[
                                                'isChecked'], // Toggle the value
                                          });

                                          // Update local state if needed
                                          setState(() {
                                            event['isChecked'] =
                                                !event['isChecked'];
                                          });
                                        } catch (e) {
                                          // print("Error updating Firestore: $e");
                                        }
                                      } else {
                                        // print("Document ID is null. Cannot update Firestore.");
                                      }
                                    },
                                    child: Icon(
                                      event['isChecked']
                                          ? Icons.check_circle
                                          : Icons.task_alt,
                                      size: 30.0,
                                      color: const Color(0xffa4392f),
                                    ),
                                  ),
                                  const SizedBox(
                                      width:
                                          15), // Add spacing between the icon and text if needed
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event['title'] ?? 'No Title',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '  ${event['description'] ?? 'No Description'}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons
                                        .arrow_forward_ios, // Replace `some_other_icon` with the icon you want to use when `isUser` is false
                                    size: 15,
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildToDoPage() {
    return CalendarPage(currentUser: currentUser);
  }

  Widget buildProfilePage() {
    return ProfilePage(currentUser: currentUser);
  }
}
