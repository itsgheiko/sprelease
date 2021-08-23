// Packages
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io' show Platform;

// Screens
import './screens/releases_screen.dart';
import './screens/log_in_screen.dart';

// Constants and theme
import './constants.dart';
import 'package:sprelease/app_theme.dart';

// Providers
import 'package:sprelease/providers/preview_player_provider.dart';

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

  @override
  Widget build(BuildContext context) {
    Future<bool> _isUserIsLoggedIn() async {
      SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();

      if (_sharedPreferences.containsKey(Constants.isLoggedInSharedPrefs)) {
        if (_sharedPreferences.getBool(Constants.isLoggedInSharedPrefs)) {
          return true;
        } else {
          return false;
        }
      } else
        return false;
    }

    Widget _child = MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          // Main
          accentColor: AppTheme.accentColor,
          scaffoldBackgroundColor: AppTheme.backgroundColor),
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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PreviewPlayerProvider()),
      ],
      child: _child,
    );
  }
}
