import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oz/Screens/UserDetailScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'UpdateUserScreen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final myUser currentUser;

  const ProfileScreen({super.key, required this.currentUser});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the current theme is dark or light
    // var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profile Page',
            style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: const Color(0xffa4392f),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding:
              const EdgeInsets.all(16.0), // Replace tDefaultSize with a value
          child: Column(
            children: [
              // -- IMAGE
              Stack(
                children: [
                  SizedBox(
                      width: 120,
                      height: 120,
                      child: CircleAvatar(
                        radius: 30.0,
                        backgroundImage: CachedNetworkImageProvider(
                            currentUser.profilePicture),
                      )),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: const Color(
                            0xffa4392f), // Replace tPrimaryColor with color value
                      ),
                      child: const Icon(
                        Icons
                            .edit, // Replaced LineAwesomeIcons.alternate_pencil
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                currentUser.name, // Replace tProfileHeading with actual text
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                currentUser
                    .email, // Replace tProfileSubHeading with actual text
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),

              // -- BUTTON
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to UpdateProfileScreen (Create the screen if needed)
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => UpdateProfileScreen(
                    //             user: currentUser,
                    //           )),
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                        0xffa4392f), // Replace tPrimaryColor with color value
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Edit Profile', // Replace tEditProfile with actual text
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 10),

              // -- MENU
              ProfileMenuWidget(
                title: "Settings",
                icon: Icons.settings, // Replaced LineAwesomeIcons.cog
                onPress: () {},
              ),
              ProfileMenuWidget(
                title: "Billing Details",
                icon: Icons
                    .account_balance_wallet, // Replaced LineAwesomeIcons.wallet
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            UserDetailScreen(user: currentUser)),
                  );
                },
              ),
              ProfileMenuWidget(
                title: "User Management",
                icon: Icons
                    .manage_accounts, // Replaced LineAwesomeIcons.user_check
                onPress: () {},
              ),
              const Divider(),
              const SizedBox(height: 10),
              ProfileMenuWidget(
                title: "Information",
                icon: Icons.info, // Replaced LineAwesomeIcons.info
                onPress: () {},
              ),
              ProfileMenuWidget(
                title: "Logout",
                icon: Icons
                    .logout, // Replaced LineAwesomeIcons.alternate_sign_out
                textColor: const Color(0xffa4392f),
                endIcon: false,
                onPress: () => _logout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final Color? textColor;
  final bool endIcon;

  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.textColor,
    this.endIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Icon(icon, color: textColor ?? Colors.black),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Colors.black),
      ),
      trailing: endIcon ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
    );
  }
}
