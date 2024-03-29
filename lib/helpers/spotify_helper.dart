// Packages
import 'dart:convert';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

// Models
import '../models/release.dart';

class SpotifyHelper {
  // To login to Spotify, get access token and access Spotify Web API
  // TODO Hide clientId and clientSecret
  static const String clientId = "36852d7f53154f368cb244a83a431f83";
  static const String clientSecret = "5bb27098a72b478d9134ccf110d84c12";
  static const String redirectUrl = "com.example.sprelease://login-callback";

  Future logIn() async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();

    // Use state in queryParameters in the future
    var _logInUri = Uri.https("accounts.spotify.com", "authorize", {
      "client_id": clientId,
      "response_type": "code",
      "redirect_uri": redirectUrl,
      "scope": "user-follow-read%20user-read-private%20user-read-email",
    });

    Future<String> getUserProfileImageUri() async {
      var _accessToken =
          _sharedPreferences.getString(Constants.accessTokenSharedPrefs);

      var _response =
          await http.get(Uri.parse("https://api.spotify.com/v1/me"), headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $_accessToken"
      });

      print(_response.body);

      if (_response.body != null) {
        var map = Map<String, dynamic>.from(jsonDecode(_response.body));
        print(map["images"][0]["url"]);
        return map["images"][0]["url"];
      } else
        return "";
    }

    try {
      // Present the dialog to the user
      final _result = await FlutterWebAuth.authenticate(
        url: "$_logInUri",
        callbackUrlScheme: "com.example.sprelease",
      );

      var _code = Uri.parse(_result).queryParameters["code"];
      await generateAccessToken(_code);

      await _sharedPreferences.setBool(Constants.isLoggedInSharedPrefs, true);

      var _profileImageUrl = await getUserProfileImageUri();
      await _sharedPreferences.setString(
          Constants.profileImageUrl, _profileImageUrl);

      return "success";
    } catch (e) {
      print(e);
      return "error";
    }
  }

  Future generateAccessToken(String code) async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();

    try {
      // Get access from Spotify Web API with POST request
      var uri = Uri.parse("https://accounts.spotify.com/api/token");
      final _response = await http.post(
        uri,
        body: {
          "grant_type": "authorization_code",
          "code": code,
          "redirect_uri": redirectUrl,
          "client_id": clientId,
          "client_secret": clientSecret,
        },
      );

      var _accessToken = jsonDecode(_response.body)["access_token"];
      var _refreshToken = jsonDecode(_response.body)["refresh_token"];

      // Save accessToken and refreshToken in Shared Preferences
      await _sharedPreferences.setString(
          Constants.accessTokenSharedPrefs, _accessToken);

      await _sharedPreferences.setString(
          Constants.refreshTokenSharedPrefs, _refreshToken);

      return "successful";
    } catch (e) {
      print(e);
      return "error";
    }
  }

  Future generateAccessTokenWithRefreshToken() async {
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();

    var _refreshTokenFromStorage =
        _sharedPreferences.getString(Constants.refreshTokenSharedPrefs);

    try {
      // Get access from Spotify Web API with POST request
      var uri = Uri.parse("https://accounts.spotify.com/api/token");
      final _response = await http.post(
        uri,
        body: {
          "grant_type": "refresh_token",
          "refresh_token": _refreshTokenFromStorage,
          "client_id": clientId,
          "client_secret": clientSecret,
        },
      );

      var _accessToken = jsonDecode(_response.body)["access_token"];
      var _refreshToken = jsonDecode(_response.body)["refresh_token"];

      // Save accessToken and refreshToken in Shared Preferences
      await _sharedPreferences.setString(
          Constants.accessTokenSharedPrefs, _accessToken);

      await _sharedPreferences.setString(
          Constants.refreshTokenSharedPrefs, _refreshToken);

      return "successful";
    } catch (e) {
      print(e);
      return "error";
    }
  }

  Future<Map> getNewReleases() async {
    List _thisWeeksReleases = [];
    List _lastWeeksReleases = [];
    List _twoWeeksAgoReleases = [];
    List _threeWeeksAgoReleases = [];
    List _olderReleases = [];

    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();

    Future getUserFollowedArtists() async {
      List _userFollowedArtists = [];

      SharedPreferences _sharedPreferences =
          await SharedPreferences.getInstance();
      var _accessToken =
          _sharedPreferences.getString(Constants.accessTokenSharedPrefs);
      var _response;
      var _path = Uri.https("api.spotify.com", "v1/me/following", {
        "type": "artist",
        "limit": "50",
      });

      try {
        _response = await http.get(
          _path,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer $_accessToken"
          },
        );
        if (_response.body != null) {
          var map = Map<String, dynamic>.from(jsonDecode(_response.body));
          if (map.containsKey("error")) {
            if (map["error"]["status"] == 401) {
              return "expired accesstoken";
            }
          } else {
            List artists = map["artists"]["items"];

            artists.forEach(
              (artist) {
                _userFollowedArtists.add(artist["id"]);
              },
            );
            return _userFollowedArtists;
          }
        }
      } catch (e) {
        // Do something on error
        print(e);
        return null;
      }
    }

    Future getLatestReleasesFromArtist(String artistUri) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var _accessToken = prefs.getString(Constants.accessTokenSharedPrefs);

      var _pathSingle =
          Uri.https("api.spotify.com", "v1/artists/$artistUri/albums", {
        "album_type": "single",
        "market": "FI",
      });

      var _pathAlbum =
          Uri.https("api.spotify.com", "v1/artists/$artistUri/albums", {
        "album_type": "album",
        "market": "FI",
      });

      var _response;

      var _now = DateTime.now();
      var _tomorrow = DateTime(_now.day + 1);
      var _weekAgo = DateTime(_now.year, _now.month, _now.day - 7);
      var _twoWeeksAgo = DateTime(_now.year, _now.month, _now.day - 14);
      var _threeWeeksAgo = DateTime(_now.year, _now.month, _now.day - 21);
      var _monthAgo = DateTime(_now.year, _now.month, _now.day - 28);
      var _twoMonthsAgo = DateTime(_now.year, _now.month, _now.day - 56);

      void addReleasesToListAccordingly(Map song) {
        void addToReleaseList(List list) {
          bool _isDuplicate = false;
          list.forEach((release) {
            if (release["name"] == song["name"]) _isDuplicate = true;
          });
          if (!_isDuplicate) {
            list.add(song);
          }
        }

        // older (month - two months)
        if ((song["date"].isAfter(_twoMonthsAgo) &&
                song["date"].isBefore(_monthAgo)) ||
            (song["date"].isAtSameMomentAs(_twoMonthsAgo) ||
                song["date"].isAtSameMomentAs(_monthAgo)))
          addToReleaseList(_olderReleases);

        // three weeks ago
        else if ((song["date"].isAfter(_monthAgo) &&
                song["date"].isBefore(_threeWeeksAgo)) ||
            song["date"].isAtSameMomentAs(_monthAgo))
          addToReleaseList(_threeWeeksAgoReleases);

        // two weeks ago
        else if ((song["date"].isAfter(_threeWeeksAgo) &&
                song["date"].isBefore(_twoWeeksAgo)) ||
            song["date"].isAtSameMomentAs(_threeWeeksAgo))
          addToReleaseList(_twoWeeksAgoReleases);

        // last week
        else if ((song["date"].isAfter(_twoWeeksAgo) &&
                song["date"].isBefore(_weekAgo)) ||
            song["date"].isAtSameMomentAs(_twoMonthsAgo))
          addToReleaseList(_lastWeeksReleases);

        // "this week"
        else if (song["date"].isAfter(_weekAgo) ||
            song["date"].isAtSameMomentAs(_weekAgo))
          addToReleaseList(_thisWeeksReleases);

        // "future" unreleased
        else if (song["date"].isAtSameMomentAs(_tomorrow))
          addToReleaseList(_thisWeeksReleases);
      }

      Future getSingles() async {
        try {
          _response = await http.get(
            _pathSingle,
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $_accessToken"
            },
          );

          if (_response.body != null) {
            var map = Map<String, dynamic>.from(jsonDecode(_response.body));
            List singles = map["items"];

            for (var single in singles) {
              if (DateTime.parse(single["release_date"])
                  .isAfter(_twoMonthsAgo)) {
                var tempArtists = "";
                for (var artist in single["artists"]) {
                  tempArtists == ""
                      ? tempArtists = "${artist["name"]}"
                      : tempArtists = "$tempArtists, ${artist["name"]}";
                }

                var _song = Release(
                  id: single["id"],
                  date: DateTime.parse(single["release_date"]),
                  name: single["name"],
                  type: "Single",
                  artists: tempArtists,
                  imageUrl: single["images"][1]["url"],
                  openUrl: single["external_urls"]["spotify"],
                ).toMap();

                addReleasesToListAccordingly(_song);
              }
            }
          }
        } catch (e) {
          print(e);
          return "error";
        }
      }

      Future getAlbums() async {
        try {
          _response = await http.get(
            _pathAlbum,
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $_accessToken"
            },
          );

          if (_response.body != null) {
            var map = Map<String, dynamic>.from(jsonDecode(_response.body));
            List albums = map["items"];

            for (var album in albums) {
              if (DateTime.parse(album["release_date"])
                  .isAfter(_twoMonthsAgo)) {
                var tempArtists = "";
                for (var artist in album["artists"]) {
                  tempArtists == ""
                      ? tempArtists = "${artist["name"]}"
                      : tempArtists = "$tempArtists, ${artist["name"]}";
                }

                var song = Release(
                        id: album["id"],
                        date: DateTime.parse(album["release_date"]),
                        name: album["name"],
                        type: "Album",
                        artists: tempArtists,
                        imageUrl: album["images"][1]["url"],
                        openUrl: album["external_urls"]["spotify"])
                    .toMap();

                addReleasesToListAccordingly(song);
              }
            }
          }
        } catch (e) {
          print(e);
          return "error";
        }
      }

      await getSingles();
      await getAlbums();
    }

    void detectNewReleases() async {
      // Detects new releases
      var _lastLoadedReleasesIdsFromSharedPrefs = _sharedPreferences
          .getStringList(Constants.lastLoadedReleasesIdsSharedPrefs);

      if (_lastLoadedReleasesIdsFromSharedPrefs != null) {
        for (var i = 0; i < _lastLoadedReleasesIdsFromSharedPrefs.length; i++) {
          if (_thisWeeksReleases.length >
              _lastLoadedReleasesIdsFromSharedPrefs.length) {
            // Releases detected
            var _numberOfNewReleases = _thisWeeksReleases.length -
                _lastLoadedReleasesIdsFromSharedPrefs.length;

            for (var i = 0; i < _numberOfNewReleases; i++) {
              _thisWeeksReleases[_thisWeeksReleases.length -
                  _numberOfNewReleases]["isNew"] = true;
            }
          } else {
            // No new releases
          }
        }
      }

      List<String> _lastLoadedReleasesIds = _thisWeeksReleases.map((release) {
        return release["id"].toString();
      }).toList();

      await _sharedPreferences.setStringList(
          Constants.lastLoadedReleasesIdsSharedPrefs, _lastLoadedReleasesIds);
    }

    var _userFollowedArtists = await getUserFollowedArtists();
    if (_userFollowedArtists == "expired accesstoken") {
      print("Access token expired, generating new");
      await SpotifyHelper().generateAccessTokenWithRefreshToken();
    }
    _userFollowedArtists = await getUserFollowedArtists();

    List<Future> _futuresToBeCompleted = [];
    for (var i = 0; i < _userFollowedArtists.length; i++) {
      _futuresToBeCompleted
          .add(getLatestReleasesFromArtist(_userFollowedArtists[i]));
    }

    // Waits for Futures for each artist to complete
    await Future.wait(_futuresToBeCompleted);

    _thisWeeksReleases.sort((a, b) {
      return b["date"].compareTo(a["date"]);
    });

    _lastWeeksReleases.sort((a, b) {
      return b["date"].compareTo(a["date"]);
    });

    _twoWeeksAgoReleases.sort((a, b) {
      return b["date"].compareTo(a["date"]);
    });

    _threeWeeksAgoReleases.sort((a, b) {
      return b["date"].compareTo(a["date"]);
    });

    _olderReleases.sort((a, b) {
      return b["date"].compareTo(a["date"]);
    });

    detectNewReleases();

    Map _map = {
      Constants.thisWeeksReleases: _thisWeeksReleases,
      Constants.lastWeeksReleases: _lastWeeksReleases,
      Constants.twoWeeksAgoReleases: _twoWeeksAgoReleases,
      Constants.threeWeeksAgoReleases: _threeWeeksAgoReleases,
      Constants.olderReleases: _olderReleases,
    };
    return _map;
  }

  Future checkForNewReleases() async {}
}
