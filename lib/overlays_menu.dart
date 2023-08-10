import 'package:flutter/material.dart';

import 'my_game.dart';

class MainMenu extends StatelessWidget {
  // Reference to parent game. Can't use HasGameRef in this non Flame class.
  final MyGame game;

  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    const darkerColour = Color.fromRGBO(191, 54, 12, 1);
    const lighterColour = Color.fromRGBO(255, 255, 255, 1);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: game.size.y / 2,
          width: game.size.x / 1.5,
          decoration: const BoxDecoration(
            color: darkerColour,
            borderRadius: BorderRadius.all(
              Radius.circular(40),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Duck Toucher',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: lighterColour,
                    fontSize: 38,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 150,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    game.overlays.remove('MainMenu');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lighterColour,
                  ),
                  child: const Text(
                    'Play',
                    style: TextStyle(
                      fontSize: 32,
                      color: darkerColour,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Touch a duck to caress it with a mallet. Try caressing as '
                'many as you can. Don\'t let number of untouched ducks get over ${game.maxDucks}!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: lighterColour,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
