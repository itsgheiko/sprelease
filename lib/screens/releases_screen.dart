// Packages
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Constants
import 'package:spreleasefaster/constants.dart';
import 'package:spreleasefaster/helpers/spotify_helper.dart';
import 'package:spreleasefaster/widgets/app_bar_button.dart';

// Models
import '../models/release.dart';

// Widgets
import '../widgets/songs_list.dart';

// Screens
import '../main.dart';

class ReleasesScreen extends StatefulWidget {
  @override
  _ReleasesScreenState createState() => _ReleasesScreenState();
}

class _ReleasesScreenState extends State<ReleasesScreen> {
  bool _isLoading = false;

  // Loads songs - called when widget loads
  Future<Map> _loadContent() async {
    Map _releases = {};
    var _result = await SpotifyHelper().getNewReleases();

    if (_result == "success") {
      var _releasesBox = await Hive.openBox(Constants.releaseBox);

      _releases[Constants.thisWeeksReleasesBox] =
          _releasesBox.get(Constants.thisWeeksReleasesBox);
      _releases[Constants.lastWeeksReleasesBox] =
          _releasesBox.get(Constants.lastWeeksReleasesBox);
      _releases[Constants.twoWeeksAgoReleasesBox] =
          _releasesBox.get(Constants.twoWeeksAgoReleasesBox);
      _releases[Constants.threeWeeksAgoReleasesBox] =
          _releasesBox.get(Constants.threeWeeksAgoReleasesBox);
      _releases[Constants.olderReleasesBox] =
          _releasesBox.get(Constants.olderReleasesBox);

      return _releases;
    } else {
      throw "error";
    }
  }

  Future<bool> _doesReleaseBoxHaveData() async {
    var _releasesBox = await Hive.openBox(Constants.releaseBox);

    if (_releasesBox.containsKey(Constants.thisWeeksReleasesBox)) {
      if (_releasesBox.get(Constants.thisWeeksReleasesBox) != null) {
        return true;
      }
    }
    return false;
  }

  Future<Map> _getReleasesFromReleaseBox() async {
    Map _releases = {};
    var _releasesBox = await Hive.openBox(Constants.releaseBox);

    _releases[Constants.thisWeeksReleasesBox] =
        _releasesBox.get(Constants.thisWeeksReleasesBox);
    _releases[Constants.lastWeeksReleasesBox] =
        _releasesBox.get(Constants.lastWeeksReleasesBox);
    _releases[Constants.twoWeeksAgoReleasesBox] =
        _releasesBox.get(Constants.twoWeeksAgoReleasesBox);
    _releases[Constants.threeWeeksAgoReleasesBox] =
        _releasesBox.get(Constants.threeWeeksAgoReleasesBox);
    _releases[Constants.olderReleasesBox] =
        _releasesBox.get(Constants.olderReleasesBox);

    return _releases;
  }

  Future<String> _getUserProfileImageUri() async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();

    return _sharedPreferences.getString(Constants.profileImageUrl);
  }

  Future _signOut() async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();

    var _releaseBox = await Hive.openBox(Constants.releaseBox);

    await _sharedPreferences.clear();
    //await _releaseBox.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(),
      ),
    );
  }

  // Widgets
  Widget songListWidget(AsyncSnapshot snapshot) {
    return SongsList(
      thisWeeksReleases: snapshot.data[Constants.thisWeeksReleasesBox],
      lastWeeksReleases: snapshot.data[Constants.lastWeeksReleasesBox],
      twoWeeksAgoReleases: snapshot.data[Constants.twoWeeksAgoReleasesBox],
      threeWeeksAgoReleases: snapshot.data[Constants.threeWeeksAgoReleasesBox],
      olderReleases: snapshot.data[Constants.olderReleasesBox],
      errorMsg: "",
    );
  }

  Widget progressIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      actions: [
        if (_isLoading)
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
            child: CircularProgressIndicator(),
          ),
        AppBarButton(
          function: () async {
            setState(() {
              _isLoading = true;
            });
            await _loadContent();
            setState(() {
              _isLoading = false;
            });
          },
          title: "Refresh",
        ),
        FutureBuilder<String>(
          future: _getUserProfileImageUri(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return Container(
                margin: EdgeInsets.fromLTRB(0, 5, 5, 5),
                child: GestureDetector(
                  onTap: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  child: Image.network(
                    snapshot.data,
                  ),
                ),
              );
            }
            return Container(
              margin: EdgeInsets.fromLTRB(0, 5, 5, 5),
              child: CircularProgressIndicator(),
            );
          },
        ),
      ],
    );
  }

  Drawer _drawer() {
    return Drawer(
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black,
        ),
        child: Column(
          children: [
            TextButton(
              onPressed: () => _signOut(),
              child: Container(
                width: double.infinity,
                height: 40,
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 5, right: 5),
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Theme.of(context).accentColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Sign out",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    return FutureBuilder<bool>(
      future: _doesReleaseBoxHaveData(),
      builder: (context, snapshot1) {
        if (snapshot1.connectionState == ConnectionState.done &&
            snapshot1.hasData) {
          if (snapshot1.data == true) {
            return FutureBuilder<Map>(
              future: _getReleasesFromReleaseBox(),
              builder: (context, snapshot2) {
                if (snapshot2.connectionState == ConnectionState.done &&
                    snapshot2.hasData) {
                  return songListWidget(snapshot2);
                }
                return progressIndicator();
              },
            );
          } else if (snapshot1.data == false) {
            return FutureBuilder<Map>(
              future: _loadContent(),
              builder: (context, snapshot3) {
                if (snapshot3.connectionState == ConnectionState.done &&
                    snapshot3.hasData) {
                  return songListWidget(snapshot3);
                } else if (snapshot3.hasError) {
                  return Center(
                    child: Text(
                      "Error, data is " + snapshot3.data.toString(),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                return progressIndicator();
              },
            );
          }
          return progressIndicator();
        }
        return progressIndicator();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _appBar(),
        endDrawer: _drawer(),
        body: _body(),
      ),
    );
  }
}
