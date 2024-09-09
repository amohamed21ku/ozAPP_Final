// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../components.dart';
//
// class SignUpPage extends StatefulWidget {
//   @override
//   _SignUpPageState createState() => _SignUpPageState();
// }
//
// class _SignUpPageState extends State<SignUpPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _idController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   File? _profilePicture;
//   bool _isLoading = false;
//
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Future<void> _pickImage() async {
//     // Check for storage permissions
//     final status = await Permission.storage.status;
//     if (!status.isGranted) {
//       // Ask for permission if not granted
//       final result = await Permission.storage.request();
//       if (!result.isGranted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content:
//                   Text('Storage permission is required to pick an image.')),
//         );
//         return;
//       }
//     }
//
//     // Proceed to pick image
//     final pickedFile =
//         await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _profilePicture = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future<void> _signUp() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       // Generate a new ID for the user document
//       final String userId = _firestore.collection('users').doc().id;
//
//       // Upload profile picture to Firebase Storage
//       String profilePictureUrl = '';
//       if (_profilePicture != null) {
//         final storageRef =
//             FirebaseStorage.instance.ref().child('profilePictures/$userId.jpg');
//         await storageRef.putFile(_profilePicture!);
//         profilePictureUrl = await storageRef.getDownloadURL();
//       }
//
//       // Save user details in Firestore
//       await _firestore.collection('users').doc(userId).set({
//         'name': _nameController.text.trim(),
//         'username': _usernameController.text.trim(),
//         'password': _passwordController.text.trim(),
//         'id': _idController.text.trim(),
//         'email': _emailController.text.trim(),
//         'profilePicture': profilePictureUrl,
//       });
//
//       // Navigate to the main page or show success message
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Sign up successful!')),
//       );
//
//       // Navigate to the HomeScreen
//       Navigator.pushReplacementNamed(context, 'homeScreen');
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//     Navigator.pop(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back,
//             color: Colors.white,
//           ),
//           onPressed: () {
//             // saveChangesToFirebase();
//             Navigator.pop(context);
//           },
//         ),
//         title: Text(
//           'Sign Up',
//           style: GoogleFonts.poppins(color: Colors.white),
//         ),
//         backgroundColor: const Color(0xffa4392f),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               GestureDetector(
//                 onTap: _pickImage,
//                 child: CircleAvatar(
//                   radius: 50,
//                   backgroundColor: const Color(0xffa4392f).withOpacity(0.5),
//                   backgroundImage: _profilePicture != null
//                       ? FileImage(_profilePicture!)
//                       : null,
//                   child: _profilePicture == null
//                       ? const Icon(Icons.add_a_photo,
//                           color: Colors.white, size: 50)
//                       : null,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               _buildTextField('Name', _nameController),
//               const SizedBox(height: 10),
//               _buildTextField('Username', _usernameController),
//               const SizedBox(height: 10),
//               _buildTextField('ID', _idController),
//               const SizedBox(height: 10),
//               _buildTextField('Email', _emailController,
//                   inputType: TextInputType.emailAddress),
//               const SizedBox(height: 10),
//               _buildTextField('Password', _passwordController,
//                   obscureText: true),
//               const SizedBox(height: 20),
//               RoundedButton(
//                 title: 'Sign Up',
//                 colour: const Color(0xffa4392f),
//                 onPressed: () async {
//                   _isLoading ? null : _signUp;
//                 },
//                 icon: Icons.arrow_forward,
//               ),
//               // ElevatedButton(
//               //   onPressed: _isLoading ? null : _signUp,
//               //   style: ElevatedButton.styleFrom(
//               //     backgroundColor: const Color(0xffa4392f), // Button color
//               //     padding: const EdgeInsets.symmetric(vertical: 16.0),
//               //   ),
//               //   child: _isLoading
//               //       ? const CircularProgressIndicator(
//               //           valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               //         )
//               //       : Text(
//               //           'Sign Up',
//               //           style: GoogleFonts.poppins(color: Colors.white),
//               //         ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField(String label, TextEditingController controller,
//       {bool obscureText = false,
//       TextInputType inputType = TextInputType.text}) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: inputType,
//       obscureText: obscureText,
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: GoogleFonts.poppins(
//           color: Colors.grey,
//         ),
//         floatingLabelStyle: GoogleFonts.poppins(
//           color: const Color(0xffa4392f),
//         ),
//         enabledBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Colors.grey),
//           borderRadius: BorderRadius.all(Radius.circular(8.0)),
//         ),
//         focusedBorder: const OutlineInputBorder(
//           borderSide: BorderSide(color: Color(0xffa4392f), width: 2.0),
//           borderRadius: BorderRadius.all(Radius.circular(16.0)),
//         ),
//       ),
//       cursorColor: const Color(0xffa4392f),
//       style: GoogleFonts.poppins(color: Colors.black),
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please enter $label';
//         }
//         return null;
//       },
//     );
//   }
// }
