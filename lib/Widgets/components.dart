import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Screens/itemDetails.dart';
import '../models/GsheetAPI.dart';
import 'mycard.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton(
      {super.key,
      required this.colour,
      required this.title,
      required this.onPressed,
      required this.icon});

  final Color colour;
  final String title;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Material(
        elevation: 10.0,
        color: colour,
        borderRadius: BorderRadius.circular(8.0),
        child: MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: onPressed,
          minWidth: 325,
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                width: 7,
              ),
              Icon(
                icon,
                color: Colors.white,
                weight: 12,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MY_textField extends StatelessWidget {
  final String hintText;
  var onchange;
  final double h;
  MY_textField(
      {super.key,
      required this.hintText,
      required this.onchange,
      required this.h});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: h,
      decoration: BoxDecoration(
          color: const Color(0xff4E4B4A),
          borderRadius: BorderRadius.circular(10)),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        onChanged: onchange,
        decoration:
            InputDecoration(border: InputBorder.none, hintText: hintText),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// -----------------------------------

class RoundedButton2 extends StatelessWidget {
  const RoundedButton2({
    super.key,
    required this.colour,
    required this.title,
    required this.onPressed,
  });

  final Color colour;
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: colour,
        borderRadius: BorderRadius.circular(20.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 325,
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                width: 7,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
//
// class RoundedButton_withicon extends StatelessWidget {
//   const RoundedButton_withicon(
//       {super.key, required this.colour,
//         required this.title,
//         required this.onPressed,
//         required this.icon});
//
//   final Color colour;
//   final String title;
//   final VoidCallback onPressed;
//   final Icon icon;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 16.0),
//       child: Material(
//         elevation: 5.0,
//         color: colour,
//         borderRadius: BorderRadius.circular(20.0),
//         child: MaterialButton(
//           onPressed: onPressed,
//           minWidth: 325,
//           height: 50,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 title,
//                 style: GoogleFonts.poppins(
//                     color: Colors.black,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600),
//               ),
//               const SizedBox(
//                 width: 7,
//               ),
//               icon,
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ----------------------=======================-----------------------
class myiconbutton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;
  final Color color;
  const myiconbutton(
      {super.key,
      required this.icon,
      required this.title,
      required this.onPressed,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            icon,
            color: color,
          ),
          onPressed: onPressed,
        ),
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 14),
        )
      ],
    );
  }
}

// =================================

class RoundedButtonSmall extends StatelessWidget {
  const RoundedButtonSmall(
      {super.key,
      required this.colour,
      required this.title,
      required this.onPressed,
      required this.width,
      required this.height,
      required this.icon,
      required this.iconColor,
      required this.textcolor});

  final Color colour;
  final String title;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final IconData icon;
  final Color iconColor;
  final Color textcolor;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      color: colour,
      elevation: 5,
      onPressed: onPressed,
      minWidth: width,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
                color: textcolor, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            width: 7,
          ),
        ],
      ),
    );
  }
}

//=====================================================================

class RoundedButtonSmall_Sharb extends StatelessWidget {
  const RoundedButtonSmall_Sharb(
      {super.key,
      required this.colour,
      required this.title,
      required this.onPressed,
      required this.width,
      required this.height,
      required this.icon,
      required this.iconColor,
      required this.textcolor});

  final Color colour;
  final String title;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final IconData icon;
  final Color iconColor;
  final Color textcolor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: colour,
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: width,
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                title,
                style: GoogleFonts.poppins(
                    color: textcolor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                width: 7,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//########################################################

class MyTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            fillColor: Colors.grey.shade200,
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[500])),
      ),
    );
  }
}

///++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++///

// previous_prices_table.dart

class PreviousPricesTable extends StatelessWidget {
  final List<Map<String, dynamic>> previousPrices;

  PreviousPricesTable({required this.previousPrices});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Previous Prices',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        DataTable(
          columns: [
            const DataColumn(label: Text('Date')),
            const DataColumn(label: Text('Price')),
          ],
          rows: previousPrices.map((price) {
            return DataRow(
              cells: [
                DataCell(Text(price['Date'] ?? '')),
                DataCell(Text(price['Price']?.toString() ?? '')),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

//==========================================================================================================

class CustomSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onChanged;
  final String hinttext;

  const CustomSearchBar({
    super.key,
    required this.searchController,
    required this.onChanged,
    required this.hinttext,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: 'Search',
        hintText: hinttext,
        hintStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w200,
          fontSize: 10,
        ),
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey,
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.grey,
        ),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Colors.grey,
                ),
                onPressed: () {
                  searchController
                      .clear(); // Clears the text in the search field
                  onChanged(
                      ''); // Calls the filter function to refresh the data
                },
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            width: 1,
            color: Colors.black45,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color(0xffa4392f),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
      ),
      cursorColor: const Color(0xffa4392f),
      style: GoogleFonts.poppins(
        fontSize: 10,
      ),
    );
  }
}

// ========================The Item Screen =========================================

class CustomItems extends StatelessWidget {
  final String SelectedItems;
  final bool isVisible;
  final TextEditingController searchController;
  final Function(String) filterData;
  final VoidCallback saveChangesToFirebase;
  final VoidCallback showColumnSelector;
  final List<String> columnOrder;
  final Map<String, bool> columnVisibility;
  List<Map<String, dynamic>> filteredList;
  final bool edit;
  final Function(int) deleteItem;
  final Future<void> Function(BuildContext, int) selectDate;
  final Future<bool?> Function(int) confirmDeleteItem;
  // final Function(String, bool) fetchDataFromFirestore;
  List<Map<String, dynamic>> dataList;

  CustomItems({
    super.key,
    required this.isVisible,
    required this.searchController,
    required this.filterData,
    required this.saveChangesToFirebase,
    required this.showColumnSelector,
    required this.columnOrder,
    required this.columnVisibility,
    required this.filteredList,
    required this.edit,
    required this.deleteItem,
    required this.selectDate,
    required this.confirmDeleteItem,
    required this.SelectedItems,
    required this.dataList,
    // required this.fetchDataFromFirestore,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // This ensures the StreamBuilder takes up the remaining space
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection(SelectedItems).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xffa4392f)),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Update dataList with live data from Firestore
          dataList = snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Add document ID to the data
            return data;
          }).toList();

          // Ensure dataList is sorted
          dataList.sort((a, b) => a['Kodu'].compareTo(b['Kodu']));

          // Only update filteredList if the search query is empty, otherwise keep the filtered items
          if (searchController.text.isEmpty) {
            filteredList = List.from(dataList);
          }

          // Now return the UI with the filtered list
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return edit
                        ? EditCard(
                            index: index,
                            item: filteredList[index],
                            onDelete: (int index) {
                              deleteItem(index);
                            },
                            selectDate: selectDate,
                            confirmDeleteItem: confirmDeleteItem,
                            columnOrder: columnOrder,
                            columnVisibility: columnVisibility,
                          )
                        : GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ItemDetailsScreen(
                                          SelectedItems: SelectedItems,
                                          item: filteredList[index],
                                          docId: filteredList[index]['id'],
                                        )),
                              );
                              //     .then((_) {
                              //   fetchDataFromFirestore(SelectedItems, true);
                              // });
                            },
                            child: ItemCard(
                              Item: filteredList[index],
                              columnOrder: columnOrder,
                              columnVisibility: columnVisibility,
                              index: index,
                            ));
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ================================================================
class VisibleActions extends StatefulWidget {
  final bool isVisible;
  final String selectedItem;
  final List<dynamic> filteredList;
  final VoidCallback saveChangesToFirebase;
  final VoidCallback showColumnSelector;

  VisibleActions({
    super.key,
    required this.isVisible,
    required this.selectedItem,
    required this.filteredList,
    required this.saveChangesToFirebase,
    required this.showColumnSelector,
  });

  @override
  _VisibleActionsState createState() => _VisibleActionsState();
}

class _VisibleActionsState extends State<VisibleActions> {
  @override
  Widget build(BuildContext context) {
    // Return the widget only if isVisible is true
    if (!widget.isVisible) {
      return const SizedBox.shrink(); // Return an empty widget when not visible
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Expanded(
                    //   child: ElevatedButton.icon(onPressed:  showAddItemBottomSheet(context,S), label: 'Add Item')
                    // ),
                    // Add the button Here
                    Expanded(
                      child: GestureDetector(
                        onTap: GsheetAPI(SelectedItems: widget.selectedItem)
                            .uploadDataToFirestore,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed:
                                  GsheetAPI(SelectedItems: widget.selectedItem)
                                      .uploadDataToFirestore,
                              icon: const Icon(
                                size: 20,
                                Icons.cloud_download_rounded,
                                color: Color(0xffa4392f),
                              ),
                            ),
                            Text(
                              'Get From Excel',
                              style: GoogleFonts.poppins(
                                color: const Color(0xffa4392f),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Expanded(
                    //   child: GestureDetector(
                    //     onTap: GsheetAPI(SelectedItems: widget.selectedItem)
                    //         .uploadDataToFirestore,
                    //     child: Row(
                    //       children: [
                    //         IconButton(
                    //           onPressed: () {
                    //             setState(() {
                    //               widget.edit = !widget.edit;
                    //             });
                    //           },
                    //           icon: const Icon(
                    //             size: 20,
                    //             Icons.edit,
                    //             color: Color(0xffa4392f),
                    //           ),
                    //         ),
                    //         Text(
                    //           'Edit Mode',
                    //           style: GoogleFonts.poppins(
                    //             color: const Color(0xffa4392f),
                    //             fontSize: 14,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.numbers),
                          const SizedBox(
                            width: 2,
                          ),
                          Text(
                            'Item Count: ${widget.filteredList.length}',
                            style: GoogleFonts.poppins(
                                color: Colors.black, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: widget.showColumnSelector,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: widget.showColumnSelector,
                              icon: const Icon(
                                size: 20,
                                Icons.view_column,
                                color: Color(0xffa4392f),
                              ),
                            ),
                            Text(
                              'Select Columns',
                              style: GoogleFonts.poppins(
                                color: const Color(0xffa4392f),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//==================================

class CustomTextField extends StatelessWidget {
  final String labelText;
  final pre;
  final suf;

  const CustomTextField({
    Key? key,
    required this.labelText,
    this.pre,
    this.suf,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        cursorColor: const Color(0xffa4392f), // Set the cursor color to red
        style: GoogleFonts.poppins(
          // Set the input text font to Google Poppins
          fontSize: 16,
          color: Colors.black, // You can change this color as needed
        ),
        decoration: InputDecoration(
          prefix: this.pre,
          suffix: this.suf,
          labelText: labelText, // Use the passed label text
          labelStyle: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey, // Default label color when not focused
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color:
                  Color(0xffa4392f), // Set the border color to red when focused
              width: 2.0,
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey, // Default border color when not focused
              width: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
