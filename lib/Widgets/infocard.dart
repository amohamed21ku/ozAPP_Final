import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InfoCard extends StatelessWidget {
  final VoidCallback onpress;
  final String name;
  final IconData icon;
  final String company;
  final String initial;
  final String customerId; // Add customerId to uniquely identify customers
  final String? profilePicture; // Add profilePicture field
  final bool isUser;

  const InfoCard({
    super.key,
    this.icon = Icons.person,
    required this.name,
    required this.company,
    required this.onpress,
    required this.initial,
    required this.customerId,
    this.profilePicture,
    required this.isUser,
  });

  Future<void> deleteCustomer(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(customerId)
          .delete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting customer')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget profIcon;
    if (profilePicture != null && profilePicture!.isNotEmpty) {
      profIcon = CircleAvatar(
        radius: 30,
        backgroundImage: CachedNetworkImageProvider(profilePicture!),
      );
    } else {
      profIcon = CircleAvatar(
        radius: 25,
        backgroundColor: const Color(0xffa4392f),
        child: Text(
          initial,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    Widget cardContent = GestureDetector(
      onTap: onpress,
      child: Material(
        elevation: 1, // Add elevation to the whole container
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(10),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  profIcon,
                  const SizedBox(
                    width: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        company,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Return the card content wrapped in a Dismissible widget if isUser is false
    if (!isUser) {
      return Dismissible(
        key: UniqueKey(), // Unique key for each card
        direction: DismissDirection.startToEnd, // Swipe direction
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  'Confirm Delete',
                  style: GoogleFonts.poppins(
                    color: const Color(0xffa4392f), // Specify the color
                  ),
                ),
                content: Text(
                  'Do you want to delete this customer?',
                  style: GoogleFonts.poppins(), // Use default Poppins style
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // Cancel deletion
                    },
                    child: Text(
                      'No',
                      style: GoogleFonts.poppins(
                        color: const Color(0xffa4392f), // Specify the color
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // Confirm deletion
                    },
                    child: Text(
                      'Yes',
                      style: GoogleFonts.poppins(
                        color: const Color(0xffa4392f), // Specify the color
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        onDismissed: (direction) async {
          // Perform deletion here if confirmed
          await deleteCustomer(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name deleted')),
          );
        },
        background: Container(
          decoration: BoxDecoration(
            color: const Color(0xffa4392f),
            borderRadius:
                BorderRadius.circular(30.0), // Adjust the radius as needed
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerLeft,
          child: const Icon(Icons.delete, color: Colors.white),
        ),

        child: cardContent,
      );
    } else {
      // Return just the card without Dismissible functionality
      return cardContent;
    }
  }
}
