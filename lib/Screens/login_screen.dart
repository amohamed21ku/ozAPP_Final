import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oz/Screens/homeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Widgets/components.dart';
import '../Widgets/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool showSpinner = false;
  String username = '';
  String pass = '';
  late SharedPreferences logindata;
  late bool isnew;

  @override
  void initState() {
    super.initState();
    checkIfAlreadyLogin();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark); // 2

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: Colors.white,
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: ModalProgressHUD(
                progressIndicator: const CircularProgressIndicator(
                  color: Color(0xffa4392f),
                  // Change spinner color to red
                  strokeWidth: 5.0, // Adjust spinner thickness if needed
                ),
                inAsyncCall: showSpinner,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      const SizedBox(
                        height: 70,
                      ),
                      SizedBox(
                        height: 70,
                        child: Hero(
                          tag: 'logo',
                          child: Image.asset(
                            'images/logo2.jpg',
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Login',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Access account',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            TextField(
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 18), // Increase font size
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (value) {
                                username = value;
                              },
                              decoration: kTextfielDecoration.copyWith(
                                hintText: "Enter your Username",
                                prefixIcon: const Icon(
                                  Icons.perm_identity,
                                  color: Colors.grey,
                                ),
                              ),
                              cursorColor: const Color(0xffa4392f),
                            ),
                            const SizedBox(
                              height: 20.0, // Increase spacing
                            ),
                            TextField(
                              style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 18), // Increase font size
                              obscureText: true,
                              onChanged: (value) {
                                pass = value;
                              },
                              decoration: kTextfielDecoration.copyWith(
                                hintText: "Enter your Password",
                                prefixIcon: const Icon(
                                  Icons.lock,
                                  color: Colors.grey,
                                ),
                              ),
                              cursorColor: const Color(0xffa4392f),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            RoundedButton(
                              title: 'Login',
                              colour: const Color(0xffa4392f),
                              onPressed: () async {
                                setState(() {
                                  showSpinner = true;
                                });

                                try {
                                  final snapshot = await FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .where('username', isEqualTo: username)
                                      .where('password', isEqualTo: pass)
                                      .get();

                                  if (snapshot.docs.isNotEmpty) {
                                    final userData = snapshot.docs.first.data();

                                    logindata.setBool('login', false);
                                    logindata.setString(
                                        'username', userData['username']);
                                    logindata.setString(
                                        'password', userData['password']);
                                    logindata.setString(
                                        'name', userData['name']);
                                    logindata.setString(
                                        'email', userData['email']);
                                    logindata.setString(
                                        "id", snapshot.docs.first.id);
                                    logindata.setString('profilePic',
                                        userData['profilePicture']);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const HomeScreen()));

                                    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => homeScreen()));
                                  } else {
                                    // Handle the case where no matching user is found
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Invalid username or password')),
                                    );
                                  }
                                  setState(() {
                                    showSpinner = false;
                                  });
                                } catch (e) {
                                  // print('Error: $e');
                                  setState(() {
                                    showSpinner = false;
                                  });
                                }
                              },
                              icon: Icons.arrow_forward,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, "signupscreen");
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an account?  ",
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: Colors.black26,
                                    ),
                                  ),
                                  Text(
                                    'Signup',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xffa4392f),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> checkIfAlreadyLogin() async {
    logindata = await SharedPreferences.getInstance();
    isnew = (logindata.getBool('login') ?? true);
    if (isnew == false) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    }
  }
}
