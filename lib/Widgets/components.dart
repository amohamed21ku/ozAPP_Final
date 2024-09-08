import 'package:flutter/cupertino.dart';
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
