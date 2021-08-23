import 'package:flutter/material.dart';

class NavigatorHelper {
  void pushToScreen(BuildContext context, Widget newScreen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return newScreen;
        },
      ),
    );
  }

  void pop(BuildContext context) {
    Navigator.pop(context);
  }
}
