import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Widgets/components.dart';

class Theitems extends StatefulWidget {
  final int ItemCount;
  bool isSearching;
  final bool isLoading;
  bool isVisible;
  bool edit;
  String selectedItem;
  final Future<void> Function() loadColumnPreferences;
  final Future<void> Function() fetchDataForSelectedItem;
  final VoidCallback showColumnSelector;

  final List<Map<String, dynamic>> dataList;
  final List<Map<String, dynamic>> filteredList;
  final List<Map<String, dynamic>> itemsToDelete;

  final TextEditingController searchController = TextEditingController();

  final List<String> columnOrder;
  final Map<String, bool> columnVisibility;
  Theitems({
    super.key,
    required this.isSearching,
    required this.isLoading,
    required this.isVisible,
    required this.edit,
    required this.selectedItem,
    required this.dataList,
    required this.filteredList,
    required this.itemsToDelete,
    required this.columnOrder,
    required this.columnVisibility,
    required this.loadColumnPreferences,
    required this.fetchDataForSelectedItem,
    required this.showColumnSelector,
    required this.ItemCount,
  });

  @override
  State<Theitems> createState() => _TheitemsState();
}

class _TheitemsState extends State<Theitems> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VisibleActions(
            isVisible: widget.isVisible,
            selectedItem: widget.selectedItem,
            ItemCount: widget.ItemCount,
            showColumnSelector: widget.showColumnSelector),
        GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta! < 0) {
              // Dragging upwards
              setState(() {
                widget.isVisible = false;
              });
            } else if (details.primaryDelta! > 0) {
              // Dragging downwards
              setState(() {
                widget.isVisible = true;
              });
            }
          },
          child: Card(
            color: const Color(0xffa4392f),
            margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(widget.isVisible ? 10.0 : 0.0),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
              child: Row(
                children: widget.columnOrder
                    .where((column) => widget.columnVisibility[column]!)
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
        ),
      ],
    );
    //   floatingActionButton: widget.edit
    //       ? FloatingActionButton(
    //           onPressed: () {
    //             widget.addNewItem;
    //           },
    //           backgroundColor: const Color(0xffa4392f),
    //           child: const Icon(Icons.add, color: Colors.white),
    //         )
    //       : null,
    // );
  }
}
