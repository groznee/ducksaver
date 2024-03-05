import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

import 'ducksprite.dart';
import 'text_boxes.dart';
import 'malletsprite.dart';
import 'parallax.dart';

class MyGame extends FlameGame
    with TapCallbacks, SingleGameInstance, HasCollisionDetection {
  //going to use this random object to get random ints and doubles
  final random = Random();
  MyParallaxComponent myparallax = MyParallaxComponent();
  int duckHits = 0; //ducks user has hit
  int maxDucks = 10; //max ducks allowed on screen before game over
  int currentDuckCount = 1; //we start with one duck
  bool duckHitBoxDrawn = false; //draws the polygonal hitbox, needs hot restart
  double _lastDuckTime = 0; //accumulator tracking time since last ducks drawn
  final double baseDuckSpawnInterval = 1.75; // new duck every x seconds
  BottomRightTextBox counterplaypauseBox = BottomRightTextBox("X");
  // BottomRightTextBox showhitboxBox = BottomRightTextBox("X"); //debugging
  // BottomRightTextBox howmanyducksHitBox = BottomRightTextBox("X"); //debugging

  @override
  Future<void> onLoad() async {
    add(myparallax);
    add(ScreenHitbox());
    add(DuckSprite(size / 2));

    //chainable double dot notation, no need for reference to an object set fields
    counterplaypauseBox = BottomRightTextBox("?", size: Vector2(45, 55))
      ..position = Vector2(size.x - 45, size.y - 55);
    add(counterplaypauseBox);

    //preloads the audio files, recheck later how to use AudioPool
    await FlameAudio.audioCache.loadAll([
      'mallet_1.mp3',
      'mallet_2.mp3',
      'mallet_3.mp3',
      'mallet_4.mp3',
      'mallet_whoosh.mp3',
      'quack_1.mp3',
      'quack_2.mp3',
      'quack_3.mp3',
      'quack_4.mp3',
      'quack_5.mp3',
      'quack_6.mp3',
      'quack_7.mp3',
      'quack_bounce.mp3',
    ]);

    // boxes used for debugging and learning  purposes, not used in final game
    // showhitboxBox = DisplayHitboxesBox("HITBOX", size: Vector2(70, 55))
    //   ..position = Vector2(size.x - 115, size.y - 55);
    // add(showhitboxBox);

    // howmanyducksHitBox =
    //     DucksHitCounterBox(duckHits.toString(), size: Vector2(45, 55))
    //       ..position = Vector2(size.x - 160, size.y - 55);
    // add(howmanyducksHitBox);
  }

  @override
  MyGame() {
    // debugMode = true; //draws borders and positions of component etc.
  }

  @override
  void update(double dt) {
    super.update(dt);

    //get the number of ducks each frame
    currentDuckCount = children.whereType<DuckSprite>().length;

    // Check if it's time to create new ducks, according to variable interval
    // and add a random number of ducks (mostly 1 or 2), depending on the score
    _lastDuckTime += dt;
    // if (_lastDuckTime >= (baseDuckSpawnInterval / (1 + duckHits / 60))) {
    //   for (int i = 0;
    //       i < (1 + random.nextDouble() * 1.5 + duckHits / 90).round();
    //       i++) {
    //     addRandomDuck();
    //   }
    //   _lastDuckTime = 0;

    double duckSpawnMultiplier = 1 + (duckHits / 75);
    double randomOffset = random.nextDouble() * 0.25;
    if (_lastDuckTime >=
        (baseDuckSpawnInterval / duckSpawnMultiplier) - randomOffset) {
      for (int i = 0;
          i < (random.nextDouble() * 1.5 + duckHits / 75).round();
          i++) {
        addRandomDuck();
      }
      _lastDuckTime = 0;

      // ... (Optional burst logic)
      if (random.nextDouble() < 0.25) {
        // 25 % chance of burst
        for (int i = 0; i < 1 + random.nextInt(3); i++) {
          addRandomDuck();
        }
      }

      //speed up parralax as well, if no overlays, layers[1] is front clouds
      if (!overlays.activeOverlays.isNotEmpty) {
        myparallax.parallax?.layers[1].velocityMultiplier
            .multiply(Vector2.all(1.1));
      }
    }

    // End game if there max ducks or more, display EndGame overlay
    if (currentDuckCount >= maxDucks) {
      pauseEngine();
      overlays.add('EndGame');
    }
  }

  void resetGame() {
    currentDuckCount = 0;
    duckHits = 0;
    removeAll(children.whereType<DuckSprite>());
    //reverses the parralax movement direction on each new game
    //set velocityMultiplier to same value as velocityMultiplierDelta in parallax.dart
    myparallax.parallax?.layers[1].velocityMultiplier.setValues(1.5, 0);
    myparallax.parallax?.baseVelocity.negate();
    resumeEngine();
    addRandomDuck();
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (!event.handled) {
      //use a different curve for misses, and set boolean isHit in constructor
      add(MalletSprite(event.canvasPosition, const SawTooth(3), isHit: false));
    } else {
      add(MalletSprite(event.canvasPosition, Curves.ease, isHit: true));
    }
  }

  // this part takes care of adding random ducks depending on score achieved

  void addRandomDuck() {
    // while overlays are active keep the ducks to third of maxDucks
    if (overlays.activeOverlays.isNotEmpty &&
        currentDuckCount >= maxDucks / 3) {
      return;
    }
    // should never add more ducks if already more than maxDucks on screen
    if (currentDuckCount >= maxDucks) return;

    final x = random.nextDouble() * size.x;
    final y = random.nextDouble() * size.y;
    add(DuckSprite(Vector2(x, y))
      ..movementVector *= (1 + duckHits / 90)
      ..duckRotationSpeed *= (1 + duckHits / 60)
      ..size /= (1 + duckHits / 90));
  }
}
