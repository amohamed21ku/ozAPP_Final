import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Widgets/infocard.dart';
import '../models/user.dart';
import 'UserDetailScreen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<myUser> users = [];
  bool showSpinner = false; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      showSpinner = true; // Show loading HUD
    });

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      users = querySnapshot.docs.map((doc) {
        final name = doc['name'] as String;
        final email = doc['email'] as String;
        final username = doc['username'] as String;
        final password = doc['password'] as String;
        final profilePicture = doc['profilePicture'] as String;
        final banksinfo = doc['banksinfo'] as Map<String, dynamic>;
        final id = doc.id;
        final initial =
            name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '';

        return myUser(
          name: name,
          email: email,
          username: username,
          password: password,
          profilePicture: profilePicture,
          id: id,
          initial: initial,
          banksinfo: banksinfo,
        );
      }).toList();
    } catch (error) {
      // Handle errors appropriately here
    }

    setState(() {
      showSpinner = false; // Hide loading HUD
    });
  }

  Future<void> _handleRefresh() async {
    await fetchUsers();
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
        backgroundColor: const Color(0xffa4392f),
        title: Text(
          'Users List',
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: showSpinner
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xffa4392f)), // Change spinner color to theme color
                ),
              )
            : RefreshIndicator(
                onRefresh: _handleRefresh,
                color: const Color(
                    0xffa4392f), // Change refresh indicator color to theme color
                backgroundColor: Colors
                    .grey[200], // Change background color of refresh indicator
                child: ListView.separated(
                  // shrinkWrap: true,
                  // physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return InfoCard(
                      profilePicture: user.profilePicture,
                      name: user.name,
                      company: user.email,
                      onpress: () {
                        // print(user.name);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailScreen(user: user),
                          ),
                        );
                      },
                      initial: user.initial,
                      customerId: '',
                      isUser:
                          true, // Assuming this is needed for the infoCard widget
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(
                    height: 4,
                  ),
                ),
              ),
      ),
    );
  }
}
