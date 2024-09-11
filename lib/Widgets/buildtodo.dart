import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BuildToDo extends StatefulWidget {
  final List events;
  final Function _refreshEvents;
  final Function _showAddEventDialog;
  final Function(int) _deleteEventFromFirestore;
  final bool showadd;

  BuildToDo({
    Key? key,
    required this.events,
    required Function refreshEvents,
    required Function showAddEventDialog,
    required Function(int) deleteEventFromFirestore,
    required showadd,
  })  : _refreshEvents = refreshEvents,
        _showAddEventDialog = showAddEventDialog,
        _deleteEventFromFirestore = deleteEventFromFirestore,
        showadd = showadd,
        super(key: key);

  @override
  State<BuildToDo> createState() => _BuildToDoState();
}

Future<void> addItemToCustomer(String docId, String kodu, String price,
    bool hanger, bool yardage, String name) async {
  try {
    // Get the current date
    DateTime now = DateTime.now();
    String formattedDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Reference to the specific document in the 'customers' collection
    DocumentReference customerDoc =
        FirebaseFirestore.instance.collection('customers').doc(docId);

    // Generate a unique item ID
    String itemId = FirebaseFirestore.instance.collection('customers').doc().id;

    // Create the new item data
    Map<String, dynamic> newItem = {
      'name': name,
      'kodu': kodu,
      'date': formattedDate,
      'price': price,
      'hanger': hanger,
      'yardage': yardage,
    };

    // Use a map to update the items field with the new item
    Map<String, dynamic> updatedItems = {itemId: newItem};

    // Update the Firestore document
    await customerDoc.update({
      'items.$itemId': newItem,
    });

    print('Item added successfully!');
  } catch (e) {
    print('Error adding item: $e');
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
              title: Text(
                'Confirm Delete',
                style: GoogleFonts.poppins(
                  color: const Color(0xffa4392f),
                ),
              ),
              content: Text(
                'Do you want to delete this Task?',
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

                      if (event['isChecked']) {
                        addItemToCustomer(
                            event['CustomerId'],
                            event['Kodu'],
                            event['Price'],
                            event['Hanger'],
                            event['Yardage'],
                            event['Name']);
                      }
                    } catch (e) {
                      print("Error updating Firestore: $e");
                    }
                  } else {
                    print("Document ID is null. Cannot update Firestore.");
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
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      event['description'] ?? 'No Description',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_back_ios,
                size: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
