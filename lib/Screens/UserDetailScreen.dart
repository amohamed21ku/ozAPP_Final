import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';

class UserDetailScreen extends StatelessWidget {
  final myUser user;

  const UserDetailScreen({super.key, required this.user});
  String getBankImage(String bankName) {
    switch (bankName) {
      case 'Ziraat Bank':
        return 'images/ziraat.jpg';
      case 'Yapi Kredi':
        return 'images/yapi.jpg';
      case 'İş Bank':
        return 'images/is.jpg';
      default:
        return 'assets/images/default.jpg'; // Provide a default image if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f2f2),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xffa4392f),
        title: Text(
          'User Detaıls',
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: const Color(0xffa4392f), width: 3.0),
                ),
                child: CircleAvatar(
                  radius: 80.0,
                  backgroundImage: CachedNetworkImageProvider(
                    user.profilePicture ?? 'https://via.placeholder.com/150',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                user.name,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                user.email,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Banking Information:',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xffa4392f),
                      ),
                    ),
                  ],
                ),
              ),
              // Display Bank Information
              ...user.banksinfo.entries.map((entry) {
                return Card(
                  color: Colors.white,
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: ListTile(
                    leading: Image.asset(
                      getBankImage(entry.key),
                      width: 40,
                      height: 40,
                    ),
                    title: Text(entry.key), // Bank Name
                    subtitle: Text(
                      "${entry.value}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: entry.value));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('IBAN copied to clipboard')),
                        );
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
