// Packages
import 'dart:convert';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sprelease/helpers/api_helper.dart';
import '../constants.dart';

// Models
import '../models/release.dart';

// Error handling
import 'package:sprelease/helpers/error_handling_helper.dart';

class SpotifyHelper {
  // To login to Spotify, get access token and access Spotify Web API
  // TODO Hide clientId and clientSecret
  static const String clientId = "729aefc6a19e4a27bb162afe13b0da0d"; // 36852d7f53154f368cb244a83a431f83
  static const String clientSecret = "753a991dacc94deaaed03bb9a1edaf4a"; // 5bb27098a72b478d9134ccf110d84c12
  static const String redirectUrl = "com.example.sprelease://login-callback";

  Future logIn() async {
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();

    // Use state in queryParameters in the future
    var _logInUri = Uri.https("accounts.spotify.com", "authorize", {
      "client_id": clientId,
      "response_type": "code",
      "redirect_uri": redirectUrl,
      "scope": "user-follow-read%20user-read-private%20user-read-email",
    });

    Future<String> getUserProfileImageUri() async {
      var _accessToken = _sharedPreferences.getString(Constants.accessTokenSharedPrefs);

      var _response = await http.get(Uri.parse("https://api.spotify.com/v1/me"), headers: {"Accept": "application/json", "Content-Type": "application/json", "Authorization": "Bearer $_accessToken"});

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
      await _sharedPreferences.setString(Constants.profileImageUrl, _profileImageUrl);

      return "success";
    } catch (e) {
      print(e);
      return "error";
    }
  }

  Future generateAccessToken(String code) async {
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();

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
      await _sharedPreferences.setString(Constants.accessTokenSharedPrefs, _accessToken);

      await _sharedPreferences.setString(Constants.refreshTokenSharedPrefs, _refreshToken);

      return "successful";
    } catch (e) {
      print(e);
      return "error";
    }
  }

  Future generateAccessTokenWithRefreshToken() async {
    SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();

    var _refreshTokenFromStorage = _sharedPreferences.getString(Constants.refreshTokenSharedPrefs);

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
      await _sharedPreferences.setString(Constants.accessTokenSharedPrefs, _accessToken);

      await _sharedPreferences.setString(Constants.refreshTokenSharedPrefs, _refreshToken);

      return "successful";
    } catch (e) {
      print(e);
      return "error";
    }
  }

  Future<Map<String, List<Release>>> getNewReleases() async {
    /**
     * 1. Gets access token from shared prefs
     * 2. Gets users followed artists and checks whether access token is expired (handles error)
     * 3. Adds all futures of getting tracks from each artist (allows all futures to complete simultaneously)
     *    All tracks are placed in appropriate list (this week, next week etc.)
     * 4. Sort lists by date
     */

    Uri _userFollowedArtistsUri = Uri.https(
      "api.spotify.com",
      "v1/me/following",
      {
        "type": "artist",
        "limit": "50",
      },
    );

    Uri _getReleasesUri(String artistId, String type) {
      return Uri.https("api.spotify.com", "v1/artists/$artistId/albums", {
        "album_type": type,
        "market": "FI",
      });
    }

    Uri _getPreviewUri(String trackId) {
      return Uri.parse("https://api.spotify.com/v1/albums/$trackId");
    }

    Map _commonHeaders(String accessToken) {
      return {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      };
    }

    List<Release> _thisWeeksReleases = [];
    List<Release> _lastWeeksReleases = [];
    List<Release> _twoWeeksAgoReleases = [];
    List<Release> _threeWeeksAgoReleases = [];
    List<Release> _olderReleases = [];

    var _now = DateTime.now();
    var _tomorrow = DateTime(_now.day + 1);
    var _weekAgo = DateTime(_now.year, _now.month, _now.day - 7);
    var _twoWeeksAgo = DateTime(_now.year, _now.month, _now.day - 14);
    var _threeWeeksAgo = DateTime(_now.year, _now.month, _now.day - 21);
    var _monthAgo = DateTime(_now.year, _now.month, _now.day - 28);
    var _twoMonthsAgo = DateTime(_now.year, _now.month, _now.day - 56);

    Future<List<String>> getUserFollowedArtists() async {
      List _userFollowedArtists = [];

      SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
      String _accessToken = _sharedPreferences.getString(Constants.accessTokenSharedPrefs);

      APIHelper().getRequest(_userFollowedArtistsUri, _commonHeaders(_accessToken)).catchError(
        (error) {
          throw ({
            "error": "Failed getting releases from Spotify API",
            "detail": "$error",
          });
        },
      ).then(
        (rawMap) async {
          List _artists = rawMap["artists"]["items"];

          _artists.forEach((artist) {
            print(artist["id"]);
            _userFollowedArtists.add(artist["id"]);
          });
        },
      );
      return _userFollowedArtists;
    }

    Future<void> getLatestReleasesFromArtist(String artistId) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var _accessToken = prefs.getString(Constants.accessTokenSharedPrefs);

      void _addReleasesToListAccordingly(Release release) {
        void addToReleaseList(List<Release> list) {
          bool _isDuplicate = false;
          list.forEach((existingRelease) {
            if (existingRelease.name == release.name) _isDuplicate = true;
          });
          if (!_isDuplicate) {
            list.add(release);
          }
        }

        DateTime d = release.date;

        // older (month - two months)
        if ((d.isAfter(_twoMonthsAgo) && d.isBefore(_monthAgo)) || (d.isAtSameMomentAs(_twoMonthsAgo) || d.isAtSameMomentAs(_monthAgo)))
          addToReleaseList(_olderReleases);

        // three weeks ago
        else if ((d.isAfter(_monthAgo) && d.isBefore(_threeWeeksAgo)) || d.isAtSameMomentAs(_monthAgo))
          addToReleaseList(_threeWeeksAgoReleases);

        // two weeks ago
        else if ((d.isAfter(_threeWeeksAgo) && d.isBefore(_twoWeeksAgo)) || d.isAtSameMomentAs(_threeWeeksAgo))
          addToReleaseList(_twoWeeksAgoReleases);

        // last week
        else if ((d.isAfter(_twoWeeksAgo) && d.isBefore(_weekAgo)) || d.isAtSameMomentAs(_twoMonthsAgo))
          addToReleaseList(_lastWeeksReleases);

        // "this week"
        else if (d.isAfter(_weekAgo) || d.isAtSameMomentAs(_weekAgo))
          addToReleaseList(_thisWeeksReleases);

        // "future" unreleased
        else if (d.isAtSameMomentAs(_tomorrow)) addToReleaseList(_thisWeeksReleases);
      }

      Future<String> _getPreviewUrl(String id) async {
        var _previewUrlResponse;

        try {
          _previewUrlResponse = await http.get(
            _getPreviewUri(id),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $_accessToken",
            },
          );

          if (_previewUrlResponse != null) {
            var _rawMap = Map<String, dynamic>.from(jsonDecode(_previewUrlResponse.body));
            return _rawMap["tracks"]["items"][0]["preview_url"];
          } else
            return "";
        } catch (e) {
          //print(e);
          return "";
        }
      }

      Future<void> _getSingles() async {
        APIHelper().getRequest(_getReleasesUri(artistId, "single"), _commonHeaders(_accessToken)).onError(
          (error, stackTrace) {
            throw ({
              "error": "Failed getting releases from Spotify API",
              "detail": "$error",
            });
          },
        ).then(
          (rawMap) async {
            List _singles = rawMap["items"];

            for (Map<String, dynamic> _single in _singles) {
              if (DateTime.parse(_single["release_date"]).isAfter(_twoMonthsAgo)) {
                var tempArtists = "";
                for (var artist in _single["artists"]) {
                  tempArtists == "" ? tempArtists = "${artist["name"]}" : tempArtists = "$tempArtists, ${artist["name"]}";
                }

                var _release = Release(
                  id: _single["id"],
                  date: DateTime.parse(_single["release_date"]),
                  name: _single["name"],
                  type: "Single",
                  artists: tempArtists,
                  imageUrl: _single["images"][1]["url"],
                  openUrl: _single["external_urls"]["spotify"],
                  previewUrl: await _getPreviewUrl(_single["id"]),
                );

                _addReleasesToListAccordingly(_release);
              }
            }
          },
        );
      }

      Future<void> _getAlbums() async {
        APIHelper().getRequest(_getReleasesUri(artistId, "album"), _commonHeaders(_accessToken)).onError(
          (error, stackTrace) {
            throw ({
              "error": "Failed getting releases from Spotify API",
              "detail": "$error",
            });
          },
        ).then(
          (rawMap) async {
            List _singles = rawMap["items"];

            for (Map<String, dynamic> _single in _singles) {
              if (DateTime.parse(_single["release_date"]).isAfter(_twoMonthsAgo)) {
                var tempArtists = "";
                for (var artist in _single["artists"]) {
                  tempArtists == "" ? tempArtists = "${artist["name"]}" : tempArtists = "$tempArtists, ${artist["name"]}";
                }

                var _release = Release(
                  id: _single["id"],
                  date: DateTime.parse(_single["release_date"]),
                  name: _single["name"],
                  type: "Single",
                  artists: tempArtists,
                  imageUrl: _single["images"][1]["url"],
                  openUrl: _single["external_urls"]["spotify"],
                  previewUrl: await _getPreviewUrl(_single["id"]),
                );

                _addReleasesToListAccordingly(_release);
              }
            }
          },
        );
      }

      /**
         * Singles and albums have to be queried seperately since Spotify's API
         * doesn't allow for both to do at the same time
         */
      await _getSingles();
      await _getAlbums();
    }

    /* void detectNewReleases() async {
      // Detects new releases
      var _lastLoadedReleasesIdsFromSharedPrefs = _sharedPreferences.getStringList(Constants.lastLoadedReleasesIdsSharedPrefs);

      if (_lastLoadedReleasesIdsFromSharedPrefs != null) {
        for (var i = 0; i < _lastLoadedReleasesIdsFromSharedPrefs.length; i++) {
          if (_thisWeeksReleases.length > _lastLoadedReleasesIdsFromSharedPrefs.length) {
            // Releases detected
            var _numberOfNewReleases = _thisWeeksReleases.length - _lastLoadedReleasesIdsFromSharedPrefs.length;

            for (var i = 0; i < _numberOfNewReleases; i++) {
              // _thisWeeksReleases[_thisWeeksReleases.length - _numberOfNewReleases].isNew = true;
            }
          } else {
            // No new releases
          }
        }
      }

      List<String> _lastLoadedReleasesIds = _thisWeeksReleases.map((release) {
        return release.id.toString();
      }).toList();

      await _sharedPreferences.setStringList(Constants.lastLoadedReleasesIdsSharedPrefs, _lastLoadedReleasesIds);
    } */

    List<String> _artists = [];
    await getUserFollowedArtists().onError(
      (error, stackTrace) async {
        if (error == ErrorHandlingHelper.expiredAccessTokenMessage) {
          await SpotifyHelper().generateAccessTokenWithRefreshToken();
        }
        return await getUserFollowedArtists();
      },
    ).catchError((error) {
      throw (error);
    }).then((artists) async {
      _artists = artists;
    });

    List<Future> _futuresToBeCompleted = List.generate(
      _artists.length,
      (i) => getLatestReleasesFromArtist(
        _artists[i],
      ),
    );

    print(_futuresToBeCompleted);

    // Waits for Futures for each artist to complete
    await Future.wait(_futuresToBeCompleted);

    _thisWeeksReleases.sort((a, b) {
      return b.date.compareTo(a.date);
    });

    _lastWeeksReleases.sort((a, b) {
      return b.date.compareTo(a.date);
    });

    _twoWeeksAgoReleases.sort((a, b) {
      return b.date.compareTo(a.date);
    });

    _threeWeeksAgoReleases.sort((a, b) {
      return b.date.compareTo(a.date);
    });

    _olderReleases.sort((a, b) {
      return b.date.compareTo(a.date);
    });

    Map<String, List<Release>> _map = {
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
