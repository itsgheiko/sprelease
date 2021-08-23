// Packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'package:sprelease/providers/preview_player_provider.dart';

class PlayButton extends StatelessWidget {
  final String trackId, previewUrl;
  PlayButton({@required this.trackId, @required this.previewUrl});

  @override
  Widget build(BuildContext context) {
    return Consumer<PreviewPlayerProvider>(
      builder: (context, provider, child) {
        bool _playing = Provider.of<PreviewPlayerProvider>(context, listen: false).getCurrentTrackIdPlaying() == trackId;
        bool _nothingIsPlaying = Provider.of<PreviewPlayerProvider>(context, listen: false).getCurrentTrackIdPlaying() == "";

        return InkWell(
          onTap: () async {
            if (_playing) {
              await provider.stopCurrentPreview();
            } else {
              if (provider.isPlaying())
                provider.goToAnotherPreview(url: previewUrl, id: trackId);
              else
                await provider.startNewPreview(id: trackId, url: previewUrl);
            }
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (_playing || _nothingIsPlaying) ? Colors.white : Colors.white.withOpacity(0.3),
            ),
            height: 40,
            width: 40,
            child: Center(
              child: Icon(
                _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 32,
              ),
            ),
          ),
        );
      },
    );
  }
}
