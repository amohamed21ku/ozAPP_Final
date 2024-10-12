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
  bool isEventPassed = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _selectedDay =
        DateTime.now(); // Set today's date as the selected date by default
  }

  bool hasEventPassed(DateTime eventDate, TimeOfDay eventTime) {
    final now = DateTime.now(); // Get the current date and time

    // Combine event date and event time to create a DateTime object
    final eventDateTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day,
      eventTime.hour,
      eventTime.minute,
    );

    // Compare eventDateTime with the current date and time
    return eventDateTime.isBefore(now);
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
      'date': _selectedDay, // Use the selected day from the calendar
      'event': event,
      'hour': time.hour,
      'minute': time.minute,
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
                borderRadius: BorderRadius.circular(20.0),
              ),
              backgroundColor: Colors.white, // Set background to white
              title: Text(
                'Add Event',
                style: GoogleFonts.poppins(
                  color: const Color(0xffa4392f), // Title color in red
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: eventController,
                    decoration: InputDecoration(
                      labelText: 'Event',
                      labelStyle: GoogleFonts.poppins(
                        color: const Color(0xffa4392f), // Label color in red
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xffa4392f), // Border color in red
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color:
                              Color(0xffa4392f), // Focused border color in red
                        ),
                      ),
                    ),
                    style: GoogleFonts.poppins(
                      color: Colors.black, // Input text color in black
                    ),
                    cursorColor: const Color(0xffa4392f), // Cursor color in red
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Time:',
                        style: GoogleFonts.poppins(
                          color: const Color(0xffa4392f), // Text color in red
                          fontSize: 16,
                        ),
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
                                    onSurface:
                                        Color(0xffa4392f), // Body text color
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(
                                          0xffa4392f), // Button text color
                                    ),
                                  ),
                                  timePickerTheme: const TimePickerThemeData(
                                    dayPeriodTextColor: Colors.black,
                                    dayPeriodColor:
                                        Color(0xbba4392f), // AM/PM background
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
                            color: const Color(
                                0xffa4392f), // Button text color in red
                          ),
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
                          Navigator.of(context).pop(); // Cancel action
                        },
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: const Color(
                                0xffa4392f), // Button text color in red
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _addEvent(eventController.text, selectedTime);
                          Navigator.of(context).pop(); // Add action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                              0xffa4392f), // Button background color in red
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          'Add',
                          style: GoogleFonts.poppins(
                            color: Colors.white, // Button text color in white
                            fontWeight: FontWeight.w600,
                          ),
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
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    //   statusBarColor: Colors.transparent, // optional
    // ));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Calendar Events',
            style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: const Color(0xffa4392f),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_box_rounded,
              size: 25,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'My Events:',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffa4392f),
                  ),
                ),
              ],
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

                      // Convert hour and minute back to TimeOfDay
                      final eventTime = TimeOfDay(
                          hour: event['hour'], minute: event['minute']);

                      return Dismissible(
                        key: Key(event['event'] + eventTime.format(context)),
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      20.0), // Rounded corners
                                ),
                                backgroundColor:
                                    Colors.white, // Set background to white
                                title: Text(
                                  'Confirm Delete',
                                  style: GoogleFonts.poppins(
                                    color: const Color(
                                        0xffa4392f), // Title color in red
                                    fontWeight: FontWeight.bold, // Bold title
                                    fontSize: 20.0, // Font size for title
                                  ),
                                ),
                                content: Text(
                                  'Do you want to delete this Event?',
                                  style: GoogleFonts.poppins(
                                    color: Colors
                                        .black, // Standard black color for the content text
                                    fontSize: 16.0, // Font size for content
                                  ),
                                ),
                                actions: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(false); // Cancel deletion
                                          },
                                          child: Text(
                                            'No',
                                            style: GoogleFonts.poppins(
                                              color: const Color(
                                                  0xffa4392f), // Button text color in red
                                              fontWeight: FontWeight
                                                  .w600, // Font weight for buttons
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                          width: 10), // Spacing between buttons
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(true); // Confirm deletion
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                                0xffa4392f), // Red background color
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12.0), // Button shape
                                            ),
                                          ),
                                          child: Text(
                                            'Yes',
                                            style: GoogleFonts.poppins(
                                              color: Colors
                                                  .white, // Button text color in white
                                              fontWeight: FontWeight
                                                  .w600, // Font weight for buttons
                                            ),
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
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _deleteEvent(event);
                        },
                        background: Container(
                          color: const Color(0xffa4392f),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Card(
                            color: hasEventPassed(
                                    DateTime.parse(
                                        event['date'].toDate().toString()),
                                    eventTime)
                                ? Color(0xfff0f0f0)
                                : Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              // trailing: const Icon(
                              //   Icons.watch_later,
                              //   color: Colors.red,
                              //   size: 22.0,
                              // ),
                              tileColor: Colors.white10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(
                                  color: hasEventPassed(
                                          DateTime.parse(event['date']
                                              .toDate()
                                              .toString()),
                                          eventTime)
                                      ? Colors.red
                                      : Colors.black,
                                  width: 0.8,
                                ),
                              ),
                              leading: GestureDetector(
                                child: Icon(
                                  Icons.label_important,
                                  color: hasEventPassed(
                                          DateTime.parse(event['date']
                                              .toDate()
                                              .toString()),
                                          eventTime)
                                      ? Color(0x99a4392f)
                                      : Color(0xffa4392f),
                                  size: 22.0,
                                ),
                              ),
                              title: Text(
                                event['event'] ?? 'No Event',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: hasEventPassed(
                                          DateTime.parse(event['date']
                                              .toDate()
                                              .toString()),
                                          eventTime)
                                      ? Colors.grey
                                      : Colors.black87,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: hasEventPassed(
                                            DateTime.parse(event['date']
                                                .toDate()
                                                .toString()),
                                            eventTime)
                                        ? Color(0x66ff0000)
                                        : Colors.grey,
                                    size: 16.0,
                                  ),
                                  const SizedBox(width: 5.0),
                                  Text(
                                    eventTime.format(context),
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
