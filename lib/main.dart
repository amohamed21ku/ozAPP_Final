import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:oz/firebase_options.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'Screens/balancesheet.dart';
import 'Screens/customerScreen.dart';
import 'Screens/homeScreen.dart';
import 'Screens/itemsScreen.dart';
import 'Screens/login_screen.dart';
import 'Screens/usersScreen.dart';
import 'Screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // initializeFirebase();

  SharedPreferences logindata = await SharedPreferences.getInstance();
  bool isNew = logindata.getBool('login') ?? true;

  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   statusBarColor: Colors.transparent,
  //   statusBarIconBrightness: Brightness.dark,
  // ));
  runApp(MyApp(isNew: isNew));
}

final ThemeData customTheme = ThemeData().copyWith(
  inputDecorationTheme: const InputDecorationTheme(
    floatingLabelStyle:
        TextStyle(color: Color(0xffa4392f)), // Floating label color
    labelStyle: TextStyle(color: Color(0xffa4392f)), // Label color
    enabledBorder: UnderlineInputBorder(
      borderSide:
          BorderSide(color: Color(0xffa4392f)), // Border color when enabled
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide:
          BorderSide(color: Color(0xffa4392f)), // Border color when focused
    ),
    hintStyle: TextStyle(color: Colors.grey), // Hint text color
  ),
  colorScheme: const ColorScheme.light(
      primary: Color(0xffa4392f)), // Set primary color for the theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor:
          const Color(0xffa4392f), // Background color for ElevatedButtons
    ),
  ),
);

class MyApp extends StatelessWidget {
  final bool isNew;

  const MyApp({super.key, required this.isNew});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: customTheme,
      initialRoute: isNew ? 'welcomescreen' : 'homescreen',
      routes: {
        "welcomescreen": (context) => const WelcomeScreen(),
        "loginscreen": (context) => const LoginScreen(),
        "homescreen": (context) => const HomeScreen(),
        "itemsscreen": (context) => const ItemsScreen(),
        "customerscreen": (context) => const CustomerScreen(),
        // "signupscreen": (context) => SignUpPage(),
        "balancesheet": (context) => const BalanceSheet(),
        "usersscreen": (context) => const UsersScreen(),
      },
    );
  }
}
