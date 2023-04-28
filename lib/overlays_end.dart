import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'my_game.dart';

class EndGame extends StatelessWidget {
  // Reference to parent game. Can't use HasGameRef in this non Flame class.
  final MyGame game;

  const EndGame({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const darkerColor = Color.fromRGBO(191, 54, 12, 1);
    const lighterColor = Color.fromRGBO(255, 255, 255, 1);
    const duckTreshold = 100; //duckHits needed to show congratulatory video

    final videoPlayerController =
        VideoPlayerController.asset('assets/video/duckrar2.mp4')
          ..setLooping(true);
    videoPlayerController.initialize();

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          //so, when duckTreshold is reached we should have a bigger container
          height: (game.duckHits >= duckTreshold)
              ? game.size.y / 1.75
              : game.size.y / 2,
          width: game.size.x / 1.5,
          decoration: const BoxDecoration(
            color: darkerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(40),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Quack overflow:\n too many ducks!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: lighterColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 175,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    videoPlayerController.dispose();
                    game.overlays.remove('EndGame');
                    game.resetGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lighterColor,
                  ),
                  child: const Text(
                    'Play again',
                    style: TextStyle(
                      fontSize: 28,
                      color: darkerColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'You quacked up and couldn\'t touch all the ducks.'
                'Try again and beat your score of ${game.duckHits} !',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: lighterColor,
                  fontSize: 18,
                ),
              ),
              if (game.duckHits >= duckTreshold)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 21.0, bottom: 7.0),
                      child: SizedBox(
                          height: 125,
                          width: 220,
                          child: VideoPlayer(videoPlayerController)
                            ..controller.play()),
                    ),
                    const Text("Quacktastic score! 🦆🔨🏆 ")
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
