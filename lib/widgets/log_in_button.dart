// Packages
import 'package:flutter/material.dart';

class LogInButton extends StatelessWidget {
  final Function logIn;
  LogInButton(this.logIn);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 60,
        width: 300,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Color(0xFF1DB954),
          borderRadius: BorderRadius.circular(50),
        ),
        child: InkWell(
          onTap: () {
            logIn();
          },
          child: const Text(
            "Login with Spotify",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
