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
    Key? key,
    required this.searchController,
    required this.onChanged,
    required this.hinttext,
  }) : super(key: key);

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
  final bool isVisible;
  final TextEditingController searchController;
  final Function(String) filterData;
  final VoidCallback saveChangesToFirebase;
  final VoidCallback showColumnSelector;
  final List<String> columnOrder;
  final Map<String, bool> columnVisibility;
  final List<Map<String, dynamic>> filteredList;
  final bool edit;
  final Function(int) deleteItem;
  final Future<void> Function(BuildContext, int) selectDate;
  final Future<bool?> Function(int) confirmDeleteItem;
  final Function(bool) fetchDataFromFirestore;

  const CustomItems({
    Key? key,
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
    required this.fetchDataFromFirestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Visibility(
          visible: isVisible,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomSearchBar(
                        searchController: searchController,
                        onChanged: filterData,
                        hinttext: 'Search by Kodu or Name',
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: GsheetAPI().uploadDataToFirestore,
                      icon: const Icon(
                        size: 25,
                        Icons.cloud_download_rounded,
                        color: Color(0xffa4392f),
                      ),
                    ),
                    IconButton(
                      onPressed: GsheetAPI().uploadDataToGoogleSheet,
                      icon: const Icon(
                        size: 25,
                        Icons.upload,
                        color: Color(0xffa4392f),
                      ),
                    ),
                    IconButton(
                      onPressed: saveChangesToFirebase,
                      icon: const Icon(
                        size: 25,
                        Icons.save,
                        color: Color(0xffa4392f),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Item Count: ${filteredList.length}',
                      style: GoogleFonts.poppins(
                          color: Colors.black, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: showColumnSelector,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: showColumnSelector,
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
                  ],
                ),
              ],
            ),
          ),
        ),
        Card(
          color: const Color(0xffa4392f),
          margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isVisible ? 10.0 : 0.0),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
            child: Row(
              children: columnOrder
                  .where((column) => columnVisibility[column]!)
                  .map((column) => Expanded(
                        child: Text(
                          column,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 12),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
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
                              item: filteredList[index],
                              docId: filteredList[index]['id'],
                            ),
                          ),
                        );
                      },
                      child: ItemCard(
                        Item: filteredList[index],
                        columnOrder: columnOrder,
                        columnVisibility: columnVisibility,
                        index: index,
                      ),
                    );
            },
          ),
        ),
      ],
    );
  }
}
