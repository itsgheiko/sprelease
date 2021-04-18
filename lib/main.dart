// Packages
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Screens
import './screens/releases_screen.dart';
import './screens/log_in_screen.dart';

// Constants
import './constants.dart';

void main() async {
  await Hive.initFlutter();

  runApp(MainScreen());
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Automatically assumes user is logged in

  Future<bool> _isUserIsLoggedIn() async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();

    if (_sharedPreferences.containsKey(Constants.isLoggedInSharedPrefs)) {
      if (_sharedPreferences.getBool(Constants.isLoggedInSharedPrefs)) {
        return true;
      } else {
        return false;
      }
    } else
      return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          accentColor: Color(0xFF1DB954), canvasColor: Colors.transparent),
      home: FutureBuilder(
        future: _isUserIsLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data ? ReleasesScreen() : LogInScreen();
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
