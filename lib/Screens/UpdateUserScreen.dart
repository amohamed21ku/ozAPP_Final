import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../models/user.dart';

class UpdateProfileScreen extends StatefulWidget {
  final myUser user;

  const UpdateProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  String? _profileImageUrl;
  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  void _initializeUserData() {
    // Initialize the form with the existing user data
    _emailController.text = widget.user.email ?? '';
    _nameController.text = widget.user.name ?? '';
    // Fetch additional data from Firestore if necessary
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.id)
        .get()
        .then((DocumentSnapshot doc) {
      if (doc.exists) {
        _usernameController.text = doc.get('username') ?? '';
        _profileImageUrl = doc.get('profilePicture');
        setState(() {});
      }
    });
  }

  Future<void> _pickProfileImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImageFile == null) return;

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_pictures/${widget.user.id}');
    await storageRef.putFile(_profileImageFile!);
    _profileImageUrl = await storageRef.getDownloadURL();
  }

  Future<void> _updateProfile() async {
    try {
      // Update profile in Firebase Auth
      // await widget.user.updateEmail(_emailController.text);
      // await widget.user.updatePassword(_passwordController.text);
      // await widget.user.updateDisplayName(_nameController.text);

      // Update profile picture if changed
      if (_profileImageFile != null) {
        await _uploadProfileImage();
      }

      // Update additional fields in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.id)
          .update({
        'username': _usernameController.text,
        'profilePicture': _profileImageUrl,
        'password': _passwordController,
        'email': _emailController
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickProfileImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImageFile != null
                    ? FileImage(_profileImageFile!)
                    : _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : null,
                child: _profileImageUrl == null && _profileImageFile == null
                    ? Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
