import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuildToDo extends StatefulWidget {
  final List events;
  final Function _refreshEvents;
  final Function _showAddEventDialog;
  final Function(int) _deleteEventFromFirestore;
  final bool showadd;

  const BuildToDo({
    super.key,
    required this.events,
    required Function refreshEvents,
    required Function showAddEventDialog,
    required Function(int) deleteEventFromFirestore,
    required this.showadd,
  })  : _refreshEvents = refreshEvents,
        _showAddEventDialog = showAddEventDialog,
        _deleteEventFromFirestore = deleteEventFromFirestore;

  @override
  State<BuildToDo> createState() => _BuildToDoState();
}

Future<void> removeItemFromCustomer(String customerId, String kodu) async {
  try {
    // Reference to the specific document in the 'customers' collection
    DocumentReference customerDoc =
        FirebaseFirestore.instance.collection('customers').doc(customerId);

    // Retrieve the customer's current data
    DocumentSnapshot customerSnapshot = await customerDoc.get();
    Map<String, dynamic>? customerData =
        customerSnapshot.data() as Map<String, dynamic>?;
    Map<String, dynamic> items = customerData?['items'] ?? {};

    // Find the item with the matching 'kodu'
    String? itemIdToRemove;
    items.forEach((itemId, itemData) {
      if (itemData['kodu'] == kodu) {
        itemIdToRemove = itemId;
      }
    });

    if (itemIdToRemove != null) {
      // Remove the item from Firestore
      await customerDoc.update({
        'items.$itemIdToRemove': FieldValue.delete(),
      });

      // print('Item removed successfully!');
    } else {
      // print('Item with kodu $kodu not found.');
    }
  } catch (e) {
    // print('Error removing item: $e');
  }
}

Future<void> addItemToCustomer(
  String customerId,
  String kodu,
  String price,
  bool hanger,
  bool yardage,
  String name,
) async {
  try {
    // Get the current date
    DateTime now = DateTime.now();
    String formattedDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Reference to the specific document in the 'customers' collection
    DocumentReference customerDoc =
        FirebaseFirestore.instance.collection('customers').doc(customerId);

    // Generate a unique item ID
    String itemId = FirebaseFirestore.instance.collection('customers').doc().id;

    // Retrieve the existing items to find the current highest order
    DocumentSnapshot customerSnapshot = await customerDoc.get();
    Map<String, dynamic>? customerData =
        customerSnapshot.data() as Map<String, dynamic>?;
    Map<String, dynamic> items = customerData?['items'] ?? {};
    int maxOrder = items.isNotEmpty
        ? items.values
            .map((item) => item['order'] as int)
            .reduce((a, b) => a > b ? a : b)
        : 0;

    // Create the new item data with the next order value
    Map<String, dynamic> newItem = {
      'name': name,
      'kodu': kodu,
      'date': formattedDate,
      'price': price,
      'hanger': hanger,
      'yardage': yardage,
      'order': maxOrder + 1, // Set the next order value
    };

    // Use a map to update the items field with the new item
    // Map<String, dynamic> updatedItems = {itemId: newItem};

    // Update the Firestore document
    await customerDoc.update({
      'items.$itemId': newItem,
    });

    // print('Item added successfully!');
  } catch (e) {
    // print('Error adding item: $e');
  }
}

class _BuildToDoState extends State<BuildToDo> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.showadd ? const Color(0xbba4392f) : Colors.white,
      elevation: widget.showadd ? 5 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: widget.showadd
            ? BorderRadius.circular(10)
            : BorderRadius.circular(0),
      ),
      child: Padding(
        padding: widget.showadd
            ? const EdgeInsets.all(10.0)
            : const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showadd)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tasks ToDo',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  if (widget.showadd)
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => widget._refreshEvents(),
                          icon: const Icon(
                            size: 25,
                            Icons.refresh,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () => widget._showAddEventDialog(),
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
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.events.length,
              itemBuilder: (context, index) {
                final event = widget.events[index];
                return _buildEventCard(context, event, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(
      BuildContext context, Map<String, dynamic> event, int index) {
    return Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      20.0), // Rounded corners for the dialog
                ),
                backgroundColor: Colors.white, // Background color of the dialog
                title: Text(
                  'Confirm Delete',
                  style: GoogleFonts.poppins(
                    color: const Color(0xffa4392f), // Title text color
                    fontWeight:
                        FontWeight.bold, // Optional bold styling for emphasis
                  ),
                ),
                content: Text(
                  'Do you want to delete this Task?',
                  style: GoogleFonts.poppins(
                    color: Colors
                        .black87, // Content text color (you can adjust this if needed)
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(false); // Close dialog with 'No' response
                        },
                        child: Text(
                          'No',
                          style: GoogleFonts.poppins(
                            color: const Color(
                                0xffa4392f), // 'No' button text color
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(true); // Close dialog with 'Yes' response
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                              0xffa4392f), // 'Yes' button background color
                        ),
                        child: Text(
                          'Yes',
                          style: GoogleFonts.poppins(
                            color: Colors.white, // 'Yes' button text color
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
        background: Container(
          color: Colors.white70,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        onDismissed: (direction) async {
          await widget._deleteEventFromFirestore(index);
        },
        child: Card(
          color: event['isChecked'] ? const Color(0xfff0f0f0) : Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: widget.showadd
                  ? Colors.white
                  : Colors.black, // Conditional border color
              width: 0.5, // Border width
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 15.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () async {
                    final docId = event['docId'];

                    if (docId != null) {
                      final docRef = FirebaseFirestore.instance
                          .collection('events')
                          .doc(docId);

                      try {
                        // Toggle the 'isChecked' value in Firestore
                        await docRef.update({
                          'isChecked': !event['isChecked'], // Toggle the value
                        });

                        // Update local state if needed
                        setState(() {
                          event['isChecked'] = !event['isChecked'];
                        });

                        // If the event is now checked, add the item to the customer
                        if (event['isChecked']) {
                          addItemToCustomer(
                            event['CustomerId'], // Ensure this exists in event
                            event['Kodu'], // Product code
                            event['Price'], // Price
                            event['Hanger'], // Boolean for hanger
                            event['Yardage'], // Boolean for yardage
                            event['Name'], // Product name
                          );
                        } else {
                          removeItemFromCustomer(
                              event['CustomerId'], event['Kodu']);
                        }
                      } catch (e) {
                        // print("Error updating Firestore: $e");
                      }
                    } else {
                      // print("Document ID is null. Cannot update Firestore.");
                    }
                  },
                  child: Icon(
                    event['isChecked'] ? Icons.check_circle : Icons.task_alt,
                    size: 30.0,
                    color: const Color(0xffa4392f),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title'] ?? 'No Title',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color:
                              event['isChecked'] ? Colors.grey : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        event['description'] ?? 'No Description',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: event['isChecked']
                              ? const Color(0xff9e9b9b)
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                // const Icon(
                //   Icons.arrow_back_ios,
                //   size: 15,
                // ),
              ],
            ),
          ),
        ));
  }
}
