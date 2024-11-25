import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailScreen extends StatefulWidget {
  final String customerId;
  final String itemId;
  final Map<String, dynamic> itemData;

  const DetailScreen({
    super.key,
    required this.customerId,
    required this.itemId,
    required this.itemData,
  });

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController koduController;
  late TextEditingController nameController;
  late TextEditingController dateController;
  late TextEditingController priceController;
  late TextEditingController notController;
  bool yardage = false;
  bool hanger = false;
  bool ld = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with item data
    koduController = TextEditingController(text: widget.itemData['kodu']);
    nameController = TextEditingController(text: widget.itemData['name']);
    dateController = TextEditingController(text: widget.itemData['date']);
    priceController = TextEditingController(text: widget.itemData['price']);
    notController = TextEditingController(text: widget.itemData['not']);

    // Initialize boolean values
    yardage = widget.itemData['yardage'] ?? false;
    hanger = widget.itemData['hanger'] ?? false;
    ld = widget.itemData['ld'] ?? false;

    // Add listener to koduController
    koduController.addListener(() {
      fetchNameByKodu(koduController.text);
    });
  }

  Future<void> fetchNameByKodu(String kodu) async {
    if (kodu.isEmpty) return;

    try {
      // Query the Firestore collection (assuming 'Polyester' collection)
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Polyester')
          .doc(kodu)
          .get();

      if (doc.exists) {
        setState(() {
          nameController.text =
              doc['Item Name'] ?? ''; // Auto-fill name if found
        });
      } else {
        print("Kodu not found");
        setState(() {
          nameController.clear(); // Clear name if no match found
        });
      }
    } catch (e) {
      print('Error fetching name by kodu: $e');
    }
  }

  Future<void> saveChanges() async {
    try {
      // Prepare updated data
      Map<String, dynamic> updatedData = {
        'kodu': koduController.text,
        'name': nameController.text,
        'date': dateController.text,
        'price': priceController.text,
        'not': notController.text,
        'yardage': yardage,
        'hanger': hanger,
        'ld': ld,
      };

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customerId)
          .update({
        'items.${widget.itemId}': updatedData,
      });

      // Pass updated data back
      Navigator.pop(context, updatedData);
    } catch (e) {
      print('Error updating item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update item')),
      );
    }
  }

  @override
  void dispose() {
    koduController.removeListener(() {
      fetchNameByKodu(koduController.text);
    });
    koduController.dispose();
    nameController.dispose();
    dateController.dispose();
    priceController.dispose();
    notController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await saveChanges();
        return true; // Allow the screen to pop
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () async {
              saveChanges();
              // Save changes to Firebase
              // saveChangesToFirebase();

              // Close the dialog or perform any other actions
              // Navigator.pop(context);
            },
          ),
          title: Text(
            'Edit Sample',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: const Color(0xffa4392f),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                _buildCustomTextField(
                    controller: koduController, label: 'Kodu'),
                const SizedBox(height: 8),
                _buildCustomTextField(
                    controller: nameController, label: 'Name'),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      dateController.text =
                          selectedDate.toString().split(' ')[0];
                    }
                  },
                  child: AbsorbPointer(
                    child: _buildCustomTextField(
                        controller: dateController, label: 'Date'),
                  ),
                ),
                const SizedBox(height: 8),
                _buildCustomTextField(
                    controller: priceController,
                    label: 'Price',
                    prefixText: '\$'),
                const SizedBox(height: 8),
                _buildCustomTextField(
                    controller: notController,
                    label: 'Note',
                    maxLines: 4,
                    isNoteField: true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildCheckbox(
                        label: 'Yardage',
                        value: yardage,
                        onChanged: (val) {
                          setState(() {
                            yardage = val ?? false;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildCheckbox(
                        label: 'Hanger',
                        value: hanger,
                        onChanged: (val) {
                          setState(() {
                            hanger = val ?? false;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildCheckbox(
                        label: 'L/D',
                        value: ld,
                        onChanged: (val) {
                          setState(() {
                            ld = val ?? false;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    String? prefixText,
    int? maxLines,
    bool isNoteField = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: isNoteField ? (maxLines ?? 4) : maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xffa4392f),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xffa4392f)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xffa4392f)),
        ),
      ),
      cursorColor: const Color(0xffa4392f),
      style: GoogleFonts.poppins(
        fontSize: 14,
      ),
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xffa4392f),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ],
    );
  }
}
