// Packages
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import './releases_screen.dart';

// Widgets
import '../widgets/log_in_button.dart';

// Constants and theme
import '../constants.dart';
import 'package:sprelease/app_theme.dart';

// Helpers
import '../helpers/spotify_helper.dart';

class LogInScreen extends StatefulWidget {
  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  bool _loading = false;

  void _goToHomeScreen() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReleasesScreen(),
      ),
    );
  }

  void _showErrorSnackBar() {
    final snackBar = SnackBar(
      backgroundColor: AppTheme.snackbarBackgroundColor,
      content: Text(
        "Something went wrong.",
        style: TextStyle(
          color: Colors.black,
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _logIn() async {
    _loading = true;
    var loggingIn = await SpotifyHelper().logIn();
    if (loggingIn == "success") {
      _goToHomeScreen();
    } else if (loggingIn == "error") {
      _loading = false;
      _showErrorSnackBar();
    } else {
      // Something went very wrong
      _loading = false;
      _showErrorSnackBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(
            width: double.infinity,
            color: AppTheme.containerBackgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LogInButton(_logIn),
                SizedBox(
                  height: 20,
                ),
                _loading
                    ? SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(),
                      )
                    : SizedBox(
                        width: 50,
                        height: 50,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
