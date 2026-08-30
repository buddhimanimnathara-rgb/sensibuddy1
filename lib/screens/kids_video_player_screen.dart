import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class KidsVideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String title;

  const KidsVideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.title,
  });

  @override
  State<KidsVideoPlayerScreen> createState() =>
      _KidsVideoPlayerScreenState();
}

class _KidsVideoPlayerScreenState
    extends State<KidsVideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,

        showVideoProgressIndicator: true,
      ),

      builder: (
          context,
          player,
          ) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.title,
            ),

            centerTitle: true,
          ),

          body: SafeArea(
            child: Column(
              children: [
                player,

                const SizedBox(
                  height: 20,
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}