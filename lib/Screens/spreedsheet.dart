import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../models/Customers.dart';

class Spreadsheet extends StatefulWidget {
  final Customer customer;

  const Spreadsheet({super.key, required this.customer});

  @override
  _SpreadsheetState createState() => _SpreadsheetState();
}

class _SpreadsheetState extends State<Spreadsheet> {
  bool isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Map<String, dynamic>> _data = [];
  final List<Map<String, dynamic>> _otherExpenses = [];
  final List<TextEditingController> _descriptionControllers = [];
  final List<TextEditingController> _quantityControllers = [];
  final List<TextEditingController> _unitPriceControllers = [];
  final List<TextEditingController> _amountControllers = [];



  double otherExpenseTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchData(widget.customer);
  }

  Future<void> _fetchData(Customer customer) async {
    setState(() => isLoading = true);

    DocumentSnapshot customerDoc =
    await _firestore.collection('customers').doc(customer.cid).get();
    if (customerDoc.exists) {
      Map<String, dynamic> goods = customerDoc['goods'];
      goods.forEach((key, value) {
        if (key.contains('good')) {
          double quantity = value['quantity']?.toDouble() ?? 0.0;
          double unitPrice = value['unit_price']?.toDouble() ?? 0.0;
          double amount = value['amount']?.toDouble() ?? 0.0;

          _data.add({
            'description': value['goods_descriptions'],
            'quantity': quantity,
            'unitPrice': unitPrice,
            'amount': amount,
          });
        }
      });

      for (var row in _data) {
        _descriptionControllers
            .add(TextEditingController(text: row['description']));
        _quantityControllers
            .add(TextEditingController(text: row['quantity'].toString()));
        _unitPriceControllers
            .add(TextEditingController(text: row['unitPrice'].toString()));
        _amountControllers
            .add(TextEditingController(text: row['amount'].toString()));
      }
    }

    setState(() => isLoading = false);
  }



  @override
  void dispose() {
    for (var controller in _descriptionControllers) {
      controller.dispose();
    }
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    for (var controller in _unitPriceControllers) {
      controller.dispose();
    }
    for (var controller in _amountControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _saveData() async {
    Map<String, Map<String, dynamic>> updatedGoods = {};
    for (int i = 0; i < _data.length; i++) {
      updatedGoods['good_$i'] = {
        'goods_descriptions': _data[i]['description'],
        'quantity': _data[i]['quantity'],
        'unit_price': _data[i]['unitPrice'],
        'amount': _data[i]['amount'],
      };
    }

    // Include other expenses in the updatedGoods map
    for (int i = 0; i < _otherExpenses.length; i++) {
      updatedGoods['other_expense_$i'] = {
        'description': _otherExpenses[i]['description'],
        'amount': _otherExpenses[i]['amount'],
      };
    }

    await _firestore.collection('customers').doc(widget.customer.cid).update({
      'goods': updatedGoods,
    });
  }


  void _addNewRow() {
    setState(() {
      _data.add({'description': '', 'quantity': 0.0, 'unitPrice': 0.0 , 'amount':0.0});
      _descriptionControllers.add(TextEditingController());
      _quantityControllers.add(TextEditingController());
      _unitPriceControllers.add(TextEditingController());
      _amountControllers.add(TextEditingController());

    });
  }

  void _deleteRow(int index) {
    setState(() {
      _data.removeAt(index);
      _descriptionControllers[index].dispose();
      _quantityControllers[index].dispose();
      _unitPriceControllers[index].dispose();
      _amountControllers[index].dispose();
      _descriptionControllers.removeAt(index);
      _quantityControllers.removeAt(index);
      _unitPriceControllers.removeAt(index);
      _amountControllers.removeAt(index);

    });
  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffa4392f),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            // _saveData();
            Navigator.pop(context);
          },
        ),
        title:  Text('Balance Sheet',style: GoogleFonts.poppins(fontSize: 20,color: Colors.white),),
      ),
      body: ModalProgressHUD(
        progressIndicator: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xffa4392f)),
          strokeWidth: 5.0,
        ),
        inAsyncCall: isLoading,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(

              children: [
            Container(
              width: 350,

            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white10, // Highlighted background color
              borderRadius: BorderRadius.circular(14.0), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  spreadRadius: 0,
                  blurRadius: 0,
                  offset: const Offset(0, 0), // Shadow position
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_pin,color: Colors.white,),
                const SizedBox(width: 8,),
                Text(
                  widget.customer.name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Text color
                  ),
                ),
              ],
            ),
            ),
                const SizedBox(height: 50,),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: Column(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SizedBox(
                                width: constraints.maxWidth, // Expand to full screen width
                                child: DataTable( // add some styling
                                  columnSpacing: 10,
                                  headingRowHeight: 40,
                                  headingRowColor: WidgetStateColor.resolveWith((states) => const Color(0xffa4392f)), // Apply background color to the entire heading row
                                  dataRowColor: WidgetStateColor.resolveWith((states) => Colors.white), // Optional: Style data rows if needed

                                  columns: [
                                    DataColumn(label: Text('Goods', style: GoogleFonts.poppins(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Quantity', style: GoogleFonts.poppins(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Price', style: GoogleFonts.poppins(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('Amount', style: GoogleFonts.poppins(fontSize: 14,color: Colors.white,fontWeight: FontWeight.bold))),
                                    DataColumn(label: Text('', style: GoogleFonts.poppins(fontSize: 0))),
                                  ],
                                  rows: List.generate(_data.length, (index) {
                                    return DataRow(cells: [
                                      DataCell(
                                        SizedBox(
                                          width: 100,
                                          child: TextField(
                                            controller: _descriptionControllers[index],
                                            style: GoogleFonts.poppins(fontSize: 12),
                                            cursorColor: const Color(0xffa4392f),
                                            decoration: const InputDecoration(
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Color(0xffa4392f), width: 1.5),
                                              ),
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                _data[index]['description'] = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 60,
                                          child: TextField(
                                            controller: _quantityControllers[index],
                                            keyboardType: TextInputType.number,
                                            style: GoogleFonts.poppins(fontSize: 12),
                                            cursorColor: const Color(0xffa4392f),
                                            decoration: const InputDecoration(
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Color(0xffa4392f), width: 1.5),
                                              ),
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                _data[index]['quantity'] = double.tryParse(value) ?? 0;
                                                _data[index]['amount'] = _data[index]['quantity'] * _data[index]['unitPrice'];
                                                _amountControllers[index].text = _data[index]['amount'].toString();
                                                _calculateTotalGoodsAmount();
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 60,
                                          child: TextField(
                                            controller: _unitPriceControllers[index],
                                            keyboardType: TextInputType.number,
                                            style: GoogleFonts.poppins(fontSize: 12),
                                            cursorColor: const Color(0xffa4392f),
                                            decoration: const InputDecoration(
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Color(0xffa4392f), width: 1.5),
                                              ),
                                              prefixText: '\$',
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                _data[index]['unitPrice'] = double.tryParse(value) ?? 0;
                                                _data[index]['amount'] = _data[index]['quantity'] * _data[index]['unitPrice'];
                                                _amountControllers[index].text = _data[index]['amount'].toString();
                                                _calculateTotalGoodsAmount();
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 60,
                                          child: TextField(
                                            controller: _amountControllers[index],
                                            keyboardType: TextInputType.number,
                                            style: GoogleFonts.poppins(fontSize: 12),
                                            cursorColor: const Color(0xffa4392f),
                                            decoration: const InputDecoration(
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Color(0xffa4392f), width: 1.5),
                                              ),
                                              prefixText: '\$',
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                _data[index]['amount'] = double.tryParse(value) ?? 0;
                                                _calculateTotalGoodsAmount();
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => _deleteRow(index),
                                        ),
                                      ),
                                    ]);
                                  }),
                                ),
                              ),
                            ),

                            // Include this inside the `build` method, just below the DataTable
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0x29a4392f),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'TOTAL:',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    Text(
                                      '\$${_calculateTotalGoodsAmount().toStringAsFixed(2)}',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _saveData,
                                    icon: const Icon(Icons.save, color: Colors.white),
                                    label: const Text(
                                      'Save',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xffa4392f),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: _addNewRow,
                                    icon: const Icon(Icons.add, color: Colors.white),
                                    label: const Text(
                                      'Add New Row',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xffa4392f),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffa4392f),
        onPressed: _addNewRow,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  double _calculateTotalGoodsAmount() {
    double total = 0;
    for (var row in _data) {
      total += row['amount'];
    }
    return total;
  }

}