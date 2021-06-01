// Packages
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

// Constants
import 'package:sprelease/constants.dart';
import 'package:sprelease/helpers/spotify_helper.dart';

// Widgets
import '../widgets/release_list.dart';

// Screens
import '../main.dart';

class ReleasesScreen extends StatefulWidget {
  @override
  _ReleasesScreenState createState() => _ReleasesScreenState();
}

class _ReleasesScreenState extends State<ReleasesScreen> {
  // Loads songs - called when widget loads
  Future<Map> _loadContent() async {
    return await SpotifyHelper().getNewReleases();
  }

  Future<String> _getUserProfileImageUri() async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();

    return _sharedPreferences.getString(Constants.profileImageUrl);
  }

  Future _signOut() async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();

    await _sharedPreferences.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(),
      ),
    );
  }

  Future<void> _refresh() async {
    // TODO Implement
  }

  // Widgets
  Widget _songListWidget(AsyncSnapshot snapshot) {
    return ReleaseList(
      thisWeeksReleases: snapshot.data[Constants.thisWeeksReleases],
      lastWeeksReleases: snapshot.data[Constants.lastWeeksReleases],
      twoWeeksAgoReleases: snapshot.data[Constants.twoWeeksAgoReleases],
      threeWeeksAgoReleases: snapshot.data[Constants.threeWeeksAgoReleases],
      olderReleases: snapshot.data[Constants.olderReleases],
      errorMsg: "",
    );
  }

  Widget _progressIndicator() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      actions: [
        FutureBuilder<String>(
          future: _getUserProfileImageUri(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return Container(
                margin: EdgeInsets.fromLTRB(0, 5, 5, 5),
                child: GestureDetector(
                  onTap: () {
                    _showPopupMenu();
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

  Widget _body() {
    return FutureBuilder<Map>(
      future: _loadContent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return _songListWidget(snapshot);
        }
        return _progressIndicator();
      },
    );
  }

  void _showPopupMenu() async {
    await showMenu(
      elevation: 0,
      color: Colors.transparent,
      context: context,
      position: RelativeRect.fromLTRB(
          double.infinity, AppBar().preferredSize.height, 0, 0),
      items: [
        PopupMenuItem(
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Color(0xFF121212),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _signOut(),
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _appBar(),
        body: _body(),
      ),
    );
  }
}
