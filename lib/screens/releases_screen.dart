// Packages
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

// Constants and theme
import 'package:sprelease/constants.dart';
import 'package:sprelease/app_theme.dart';

// Widgets
import '../widgets/release_list_widgets/release_list.dart';

// Helpers
import 'package:sprelease/helpers/spotify_helper.dart';
import '../helpers/navigator_helper.dart';

// Screens
import '../main.dart';
import 'package:sprelease/screens/preferences_screen.dart';

// Providers
import 'package:sprelease/providers/preview_player_provider.dart';

// Models
import 'package:sprelease/models/release.dart';

class ReleasesScreen extends StatefulWidget {
  @override
  _ReleasesScreenState createState() => _ReleasesScreenState();
}

class _ReleasesScreenState extends State<ReleasesScreen> with WidgetsBindingObserver {
  // Instantiate preview player
  AssetsAudioPlayer _player = AssetsAudioPlayer();

  // Loads songs - called when widget loads
  Future<Map<String, List<Release>>> _loadContent() async {
    return await SpotifyHelper().getNewReleases();
  }

  Future<String> _getUserProfileImageUri() async {
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();

    return _sharedPreferences.getString(Constants.profileImageUrl);
  }

  Future _signOut() async {
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();

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
      backgroundColor: AppTheme.backgroundColor,
      actions: [
        FutureBuilder<String>(
          future: _getUserProfileImageUri(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
              return Container(
                margin: EdgeInsets.fromLTRB(0, 5, 5, 5),
                child: GestureDetector(
                  onTap: () {
                    NavigatorHelper().pushToScreen(
                      context,
                      PreferencesScreen(),
                    );
                  },
                  child: Image.network(
                    snapshot.data,
                    height: 50,
                    width: 50,
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
    return FutureBuilder<Map<String, List<Release>>>(
      future: _loadContent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return _songListWidget(snapshot);
        }
        return _progressIndicator();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _player.dispose();
    Provider.of<PreviewPlayerProvider>(context, listen: false).endPlayerSession();

    super.dispose();
  }

  // Handles closing app
  @override
  didChangeAppLifecycleState(AppLifecycleState state) async {
    if (AppLifecycleState.paused == state) {
      await Provider.of<PreviewPlayerProvider>(context, listen: false).stopCurrentPreview();
    } else if (AppLifecycleState.resumed == state) {
      await Provider.of<PreviewPlayerProvider>(context, listen: false).stopCurrentPreview();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Save instance of player
    Provider.of<PreviewPlayerProvider>(context, listen: false).setPlayerInstance(_player);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _appBar(),
        body: _body(),
      ),
    );
  }
}
