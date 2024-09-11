import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ordersSheet extends StatefulWidget {
  final String customerName;

  const ordersSheet({Key? key, required this.customerName}) : super(key: key);

  @override
  _ordersSheetState createState() => _ordersSheetState();
}

class _ordersSheetState extends State<ordersSheet> {
  List<Map<String, dynamic>> _data = [];
  List<TextEditingController> _descriptionControllers = [];
  List<TextEditingController> _quantityControllers = [];
  List<TextEditingController> _unitPriceControllers = [];
  List<TextEditingController> _amountControllers = [];

  bool isLoading = false;

  void _addNewRow() {
    setState(() {
      _data.add({
        'description': '',
        'quantity': 0.0,
        'unitPrice': 0.0,
        'amount': 0.0,
      });
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
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Balance Sheet',
          style: GoogleFonts.poppins(fontSize: 20, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Container(
                width: 350,
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(14.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      spreadRadius: 0,
                      blurRadius: 0,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_pin,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.customerName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              _buildDataTable(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
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
      ),
    );
  }

  Widget _buildDataTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 10,
            headingRowHeight: 40,
            headingRowColor: MaterialStateProperty.resolveWith(
                (states) => const Color(0xffa4392f)),
            columns: [
              _buildColumn('Goods'),
              _buildColumn('Quantity'),
              _buildColumn('Price'),
              _buildColumn('Amount'),
              const DataColumn(label: Text('')),
            ],
            rows: List.generate(_data.length, (index) {
              return DataRow(cells: [
                _buildEditableCell(
                    _descriptionControllers[index], index, 'description'),
                _buildEditableCell(
                    _quantityControllers[index], index, 'quantity'),
                _buildEditableCell(
                    _unitPriceControllers[index], index, 'unitPrice'),
                _buildEditableCell(_amountControllers[index], index, 'amount'),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteRow(index),
                  ),
                ),
              ]);
            }),
          ),
        );
      },
    );
  }

  DataColumn _buildColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  DataCell _buildEditableCell(
      TextEditingController controller, int index, String field) {
    return DataCell(
      SizedBox(
        width: 100,
        child: TextField(
          controller: controller,
          style: GoogleFonts.poppins(fontSize: 12),
          cursorColor: const Color(0xffa4392f),
          decoration: const InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffa4392f), width: 1.5),
            ),
          ),
          onChanged: (value) {
            setState(() {
              if (field == 'quantity' || field == 'unitPrice') {
                _data[index][field] = double.tryParse(value) ?? 0.0;
                _data[index]['amount'] =
                    _data[index]['quantity'] * _data[index]['unitPrice'];
                _amountControllers[index].text =
                    _data[index]['amount'].toStringAsFixed(2);
              } else {
                _data[index][field] = value;
              }
            });
          },
        ),
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

  void _saveData() {
    // Logic to save data
  }
}
