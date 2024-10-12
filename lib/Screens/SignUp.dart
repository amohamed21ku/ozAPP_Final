// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart' as perm_handler;
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:uuid/uuid.dart';
//
// class SignUpPage extends StatefulWidget {
//   @override
//   _SignUpPageState createState() => _SignUpPageState();
// }
//
// class _SignUpPageState extends State<SignUpPage> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   File? _profileImage;
//   final ImagePicker _picker = ImagePicker();
//   final _uuid = Uuid(); // For generating a random user ID
//
//   Future<void> _getPermission() async {
//     if (Platform.isAndroid) {
//       var status = await perm_handler.Permission.storage.status;
//       if (status.isGranted) {
//         // Permission is already granted, open image picker
//         _pickProfileImage();
//       } else if (status.isDenied) {
//         // Request permission
//         status = await perm_handler.Permission.storage.request();
//         if (status.isGranted) {
//           _pickProfileImage();
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text('Permission to access storage was denied'),
//           ));
//         }
//       } else if (status.isPermanentlyDenied) {
//         // If permission is permanently denied, open app settings
//         openAppSettings();
//       }
//     } else if (Platform.isIOS) {
//       var status = await perm_handler.Permission.photos.status;
//       if (status.isGranted) {
//         _pickProfileImage();
//       } else if (status.isDenied) {
//         // Request permission
//         status = await perm_handler.Permission.photos.request();
//         if (status.isGranted) {
//           _pickProfileImage();
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//             content: Text('Permission to access photos was denied'),
//           ));
//         }
//       } else if (status.isPermanentlyDenied) {
//         openAppSettings();
//       }
//     }
//   }
//
//   Future<void> _pickProfileImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _profileImage = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future<String> _uploadProfileImageToStorage(String userId) async {
//     if (_profileImage == null) return '';
//
//     final storageRef =
//         FirebaseStorage.instance.ref().child('profilePictures/$userId');
//     await storageRef.putFile(_profileImage!);
//     return await storageRef.getDownloadURL();
//   }
//
//   Future<void> _signUpUser() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         // Generate a random user ID
//         String userId = _uuid.v4();
//
//         String profilePicUrl = await _uploadProfileImageToStorage(userId);
//
//         // Add user info to Firestore
//         await FirebaseFirestore.instance.collection('users').doc(userId).set({
//           'email': _emailController.text.trim(),
//           'name': _nameController.text.trim(),
//           'username': _usernameController.text.trim(),
//           'password':
//               _passwordController.text.trim(), // Store hashed in production
//           'profilePicture': profilePicUrl,
//           'baksinfo': {}, // Empty map
//           'calender_events': {} // Empty map
//         });
//
//         // Show success or navigate to another screen
//       } catch (e) {
//         // Handle errors (e.g. display a snackbar)
//         print('Error: $e');
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Sign Up')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(labelText: 'Name'),
//                 validator: (value) => value!.isEmpty ? 'Enter your name' : null,
//               ),
//               TextFormField(
//                 controller: _emailController,
//                 decoration: InputDecoration(labelText: 'Email'),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter your email' : null,
//               ),
//               TextFormField(
//                 controller: _usernameController,
//                 decoration: InputDecoration(labelText: 'Username'),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter your username' : null,
//               ),
//               TextFormField(
//                 controller: _passwordController,
//                 decoration: InputDecoration(labelText: 'Password'),
//                 obscureText: true,
//                 validator: (value) => value!.length < 6
//                     ? 'Password must be at least 6 characters'
//                     : null,
//               ),
//               SizedBox(height: 10),
//               _profileImage == null
//                   ? Text('No Profile Image Selected')
//                   : Image.file(_profileImage!, height: 100, width: 100),
//               ElevatedButton(
//                 onPressed: _getPermission,
//                 child: Text('Pick Profile Image'),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _signUpUser,
//                 child: Text('Sign Up'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
