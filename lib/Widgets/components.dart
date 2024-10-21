import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

//==================================
class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final pre;
  final suf;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.pre,
    this.suf,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enabled,
      controller: controller,
      cursorColor: const Color(0xffa4392f),
      style: GoogleFonts.poppins(
        fontSize: 16,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        prefix: pre,
        suffix: suf,
        labelText: labelText,
        labelStyle: GoogleFonts.poppins(
          fontSize: 16,
          color: Colors.grey,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xffa4392f),
            width: 2.0,
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
