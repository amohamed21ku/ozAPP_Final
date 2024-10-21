import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class MyCard extends StatefulWidget {
  final ValueChanged<String> onChangedKodu;
  final ValueChanged<String> onChangedName;
  final ValueChanged<String> onChangedDate;
  final ValueChanged<String> onChangedPrice;
  final ValueChanged<bool> onChangedYardage;
  final ValueChanged<bool> onChangedHanger;
  final String kodu;
  final String name;
  final String date;
  final String price;
  final bool yardage;
  final bool hanger;

  const MyCard({
    super.key,
    required this.onChangedKodu,
    required this.onChangedName,
    required this.onChangedDate,
    required this.onChangedPrice,
    required this.onChangedYardage,
    required this.onChangedHanger,
    required this.kodu,
    required this.name,
    required this.date,
    required this.price,
    required this.yardage,
    required this.hanger,
  });

  @override
  _MyCardState createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  late TextEditingController _koduController;
  late TextEditingController _nameController;
  late TextEditingController _dateController;
  late TextEditingController _priceController;
  late bool _yardage;
  late bool _hanger;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _koduController = TextEditingController(text: widget.kodu);
    _nameController = TextEditingController(text: widget.name);

    // Set today's date as the default date
    _dateController = TextEditingController(
      text: widget.date.isEmpty
          ? DateTime.now().toString().split(' ')[0]
          : widget.date,
    );

    _priceController = TextEditingController(text: widget.price);
    _yardage = widget.yardage;
    _hanger = widget.hanger;

    _koduController.addListener(() {
      _onTextChanged(_koduController.text, widget.onChangedKodu);
    });

    _nameController.addListener(() {
      _onTextChanged(_nameController.text, widget.onChangedName);
    });

    _dateController.addListener(() {
      _onTextChanged(_dateController.text, widget.onChangedDate);
    });

    _priceController.addListener(() {
      _onTextChanged(_priceController.text, widget.onChangedPrice);
    });
  }

  void _onTextChanged(String text, ValueChanged<String> onChanged) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      onChanged(text);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _koduController.dispose();
    _nameController.dispose();
    _dateController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: const BorderSide(color: Color(0xffa4392f), width: 1),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTextField(_koduController, 'Kodu'),
                const SizedBox(width: 8),
                _buildTextField(_nameController, 'Name'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField(_dateController, 'Date',
                          expanded: false),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildTextField(_priceController, 'Price'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCheckbox('Yardage', _yardage, (value) {
                  setState(() => _yardage = value);
                  widget.onChangedYardage(value);
                }),
                _buildCheckbox('Hanger', _hanger, (value) {
                  setState(() => _hanger = value);
                  widget.onChangedHanger(value);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool expanded = true}) {
    late String pre;
    if (label == 'Price') {
      pre = "\$ ";
    } else {
      pre = "";
    }

    Widget textField = TextField(
      decoration: InputDecoration(
        prefix: Text(pre),
        labelText: label,
        labelStyle:
            GoogleFonts.poppins(fontSize: 14, color: const Color(0xffa4392f)),
        isDense: true,
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xffa4392f)),
        ),
      ),
      cursorColor: const Color(0xffa4392f),
      controller: controller,
    );

    if (expanded) {
      return Expanded(child: textField);
    }
    return textField;
  }

  Widget _buildCheckbox(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        Checkbox(
          value: value,
          onChanged: (bool? newValue) {
            if (newValue != null) {
              onChanged(newValue); // Ensure we pass a non-null value
            }
          },
          activeColor: const Color(0xffa4392f),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xffa4392f)),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      String formattedDate = picked.toString().split(' ')[0];
      widget.onChangedDate(formattedDate);
      setState(() {
        _dateController.text = formattedDate;
      });
    }
  }
}

// =========================================================================

// =====================================================================================================================

class ItemCard extends StatelessWidget {
  final List<String> columnOrder;
  final Map<String, bool> columnVisibility;
  final Map<String, dynamic> Item;
  final int index;

  const ItemCard({
    super.key,
    required this.columnOrder,
    required this.columnVisibility,
    required this.Item,
    required this.index,
  });

  String formatDateString(DateTime date) {
    // Replace with your custom date formatting logic
    return '${date.year}-${date.month}-${date.day}';
  }

  DateTime excelSerialDateToDateTime(int value) {
    // Replace with your logic to convert serial date to DateTime
    return DateTime(1900).add(Duration(days: value - 2));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0), // Adjust the radius here
      ),
      color: const Color(0xfffcfcfc),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Row(
          children: columnOrder
              .where((column) => columnVisibility[column]!)
              .map((column) {
            final value = Item[column] ?? Item['Item $column'];
            return Expanded(
              child: Text(
                column == 'Date' && value is int
                    ? formatDateString(excelSerialDateToDateTime(value))
                    : value.toString(),
                style: GoogleFonts.poppins(fontSize: 12),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
