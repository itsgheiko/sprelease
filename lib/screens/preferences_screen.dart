// Packages
import 'package:flutter/material.dart';
import 'dart:io' show Platform;

// Helpers
import 'package:sprelease/helpers/navigator_helper.dart';

// Theme
import 'package:sprelease/app_theme.dart';

class PreferencesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget _topBar() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Settings",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          if (Platform.isAndroid)
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                NavigatorHelper().pop(context);
              },
            ),
        ],
      );
    }

    Widget _preferences() {
      return Expanded(
        child: ListView.separated(
          itemCount: 10,
          itemBuilder: (context, i) {
            return Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey),
              height: 100,
            );
          },
          separatorBuilder: (context, i) {
            return SizedBox(
              height: 10,
            );
          },
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              _topBar(),
              SizedBox(
                height: 20,
              ),
              _preferences(),
            ],
          ),
        ),
      ),
    );
  }
}
