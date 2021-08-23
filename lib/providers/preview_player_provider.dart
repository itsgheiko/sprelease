// Packages
import 'package:flutter/material.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

class PreviewPlayerProvider extends ChangeNotifier {
  AssetsAudioPlayer _player;
  String _currentTrackIdPlaying = "";

  AssetsAudioPlayer getPlayer() => _player;
  String getCurrentTrackIdPlaying() => _currentTrackIdPlaying;

  void setPlayerInstance(AssetsAudioPlayer player) {
    _player = player;
  }

  Future playAudio({String url}) async {
    try {
      await _player.open(
        Audio.network(url),
        loopMode: LoopMode.playlist,
      );
    } catch (e) {
      print(e);
    }
  }

  Future startNewPreview({String url, String id}) async {
    // When nothing is playing and the "play" button is pressed
    await _player.stop();
    await playAudio(url: url);
    _currentTrackIdPlaying = id;
    notifyListeners();
  }

  Future stopCurrentPreview() async {
    // When "pause" button is clicked
    await _player.stop();
    _currentTrackIdPlaying = "";
    notifyListeners();
  }

  Future goToAnotherPreview({String url, String id}) async {
    // When another preview is clicked as another still plays
    await _player.stop();
    await playAudio(url: url);
    _currentTrackIdPlaying = id;
    notifyListeners();
  }

  // Other
  bool isPlaying() {
    bool _isPlaying = true;

    PlayerBuilder.isPlaying(
        player: _player,
        builder: (context, isPlaying) {
          if (isPlaying) isPlaying = true;
          return;
        });

    return _isPlaying;
  }

  Future pauseAudio() async {
    await _player.pause();
    notifyListeners();
  }

  Future resumeAudio() async {
    await _player.play();
    notifyListeners();
  }

  Future endPlayerSession() async {
    await _player.dispose();
    notifyListeners();
  }
}
