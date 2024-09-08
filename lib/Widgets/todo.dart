import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oz/models/user.dart'; // Import the user model

class CalendarPage extends StatefulWidget {
  final myUser currentUser;

  const CalendarPage({super.key, required this.currentUser});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _selectedDay =
        DateTime.now(); // Set today's date as the selected date by default
  }

  // Fetching events for the selected day
  Future<List<Map<String, dynamic>>> _getEventsForDay(DateTime day) async {
    List<Map<String, dynamic>> events = [];

    // Fetch the user document
    final docSnapshot =
        await _firestore.collection('users').doc(widget.currentUser.id).get();

    // Check if the document exists and if it contains the 'calender_events' field
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data['calender_events'] != null) {
        // Filter events to include only those that match the selected day
        final allEvents =
            List<Map<String, dynamic>>.from(data['calender_events']);
        final filteredEvents = allEvents
            .where((event) =>
                isSameDay((event['date'] as Timestamp).toDate(), day))
            .toList();
        events.addAll(filteredEvents);
      }
    }
    return events;
  }

  // Adding a new event for the selected day
  Future<void> _addEvent(String event, TimeOfDay time) async {
    final newEvent = {
      'date': _selectedDay, // Ensure _selectedDay is not null
      'event': event,
      'time': time.format(context),
    };

    // Get the current list of events
    final docSnapshot =
        await _firestore.collection('users').doc(widget.currentUser.id).get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      List<Map<String, dynamic>> events = [];

      if (data != null && data['calender_events'] != null) {
        events = List<Map<String, dynamic>>.from(data['calender_events']);
      }

      // Add the new event to the list
      events.add(newEvent);

      // Save the updated list back to Firestore
      await _firestore.collection('users').doc(widget.currentUser.id).update({
        'calender_events': events,
      });
    } else {
      // If the document doesn't exist, create it with the new event
      await _firestore.collection('users').doc(widget.currentUser.id).set({
        'calender_events': [newEvent],
      });
    }

    setState(() {});
  }

  // Deleting an event from Firebase
  Future<void> _deleteEvent(Map<String, dynamic> eventToDelete) async {
    final docSnapshot =
        await _firestore.collection('users').doc(widget.currentUser.id).get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null && data['calender_events'] != null) {
        List<Map<String, dynamic>> events =
            List<Map<String, dynamic>>.from(data['calender_events']);
        events.removeWhere((event) =>
            event['event'] == eventToDelete['event'] &&
            event['time'] == eventToDelete['time'] &&
            (event['date'] as Timestamp).toDate() ==
                (eventToDelete['date'] as Timestamp).toDate());

        await _firestore
            .collection('users')
            .doc(widget.currentUser.id)
            .update({'calender_events': events});
      }
    }

    setState(() {});
  }

  // Show a dialog to add a new event
  void _showAddEventDialog() {
    final eventController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(20.0), // Adjust the corner radius
                side: const BorderSide(
                  color: Colors.grey, // Border color
                  width: 2.0, // Border width
                ),
              ),
              backgroundColor:
                  const Color(0xffa4392f), // Change the background color
              title: Text(
                'Add Event',
                style: GoogleFonts.poppins(
                    color: Colors.white), // Title text color
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: eventController,
                    decoration: InputDecoration(
                      labelText: 'Event',
                      labelStyle: GoogleFonts.poppins(
                          color: Colors.white), // Title text color
                      // Input label text color
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white), // Input border color
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
                  Row(
                    children: [
                      Text(
                        'Time:',
                        style: GoogleFonts.poppins(
                            color: Colors.white), // Title text color
                        // Text color
                      ),
                      TextButton(
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(
                                        0xffa4392f), // Header background color
                                    onPrimary:
                                        Colors.white, // Header text color
                                    onSurface: Color(0xffa4392f),
                                    // Body text color
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(
                                          0xffa4392f), // Button text color
                                    ),
                                  ),
                                  timePickerTheme: const TimePickerThemeData(
                                    dayPeriodTextColor: Colors.black,
                                    dayPeriodColor: Color(0xbba4392f),
                                    // AM/PM text color
                                    dayPeriodShape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null && picked != selectedTime) {
                            setState(() {
                              selectedTime = picked;
                            });
                          }
                        },
                        child: Text(
                          selectedTime.format(context),
                          style: GoogleFonts.poppins(
                              color: Colors.white), // Button text color
                        ),
                      ),
                    ],
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
                          _addEvent(eventController.text, selectedTime);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Add',
                          style: GoogleFonts.poppins(
                              color: Colors.black), // Title text color
                          // Button text color
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
    );
  }

  // Building the UI
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent, // optional
    ));
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Calendar Events',
            style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: const Color(0xffa4392f),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: _showAddEventDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false, // Hide the format button
            ),
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color(0xbea4392f),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xffa4392f),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: Colors.white),
              selectedTextStyle: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getEventsForDay(_selectedDay ?? _focusedDay),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xffa4392f)),
                  ));
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error loading events'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No events for this day'));
                } else {
                  final events = snapshot.data!;
                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Dismissible(
                        key: Key(event['event'] + event['time']),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) {
                          _deleteEvent(event);
                        },
                        background: Container(
                          color: const Color(0xffa4392f),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Card(
                            elevation:
                                4, // Reduced elevation for a subtler shadow effect
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  12), // Slightly smaller border radius
                            ),
                            child: ListTile(
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                              tileColor: Colors.white10, // Lighter tile color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                side: BorderSide(
                                  color: const Color(0xffa4392f).withOpacity(
                                      0.7), // Adjusted border color for better contrast
                                  width: 0.8,
                                ),
                              ),
                              leading: GestureDetector(
                                child: const Icon(
                                  Icons.label_important,
                                  color: Color(0xffa4392f),
                                  size: 22.0, // Slightly smaller icon
                                ),
                              ),
                              title: Text(
                                event['event'] ?? 'No Event',
                                style: GoogleFonts.poppins(
                                  fontSize: 15, // Slightly smaller font size
                                  fontWeight: FontWeight
                                      .w600, // Medium weight for better readability
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.grey,
                                    size: 16.0,
                                  ),
                                  const SizedBox(width: 5.0),
                                  Text(
                                    event['time'] ?? 'No Time',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
