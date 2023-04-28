import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/animation.dart';

import 'ducksprite.dart';
import 'text_boxes.dart';
import 'malletsprite.dart';

class MyGame extends FlameGame
    with HasTappableComponents, HasCollisionDetection, SingleGameInstance {
  //going to use this random object to get random ints and doubles
  final random = Random();
  int duckHits = 0; //ducks user has hit
  int maxDucks = 10; //max ducks allowed on screen before game over
  int ducksExisting = 1; //we start with one duck
  bool duckHitBoxDrawn = false; //draws the polygonal hitbox, needs hot restart
  double _lastDuckTime = 0; //accumulator tracking time since last ducks drawn
  final double _duckInterval = 2.15; // create a new duck every x seconds
  BottomRightTextBox counterplaypauseBox = BottomRightTextBox("X");
  // BottomRightTextBox showhitboxBox = BottomRightTextBox("X"); //debugging
  // BottomRightTextBox howmanyducksHitBox = BottomRightTextBox("X"); //debugging

  @override
  Future<void> onLoad() async {
    add(ScreenHitbox());
    add(DuckSprite(size / 2));

    //chainable double dot notation, no need for reference to an object set fields
    counterplaypauseBox = BottomRightTextBox("?", size: Vector2(45, 55))
      ..position = Vector2(size.x - 45, size.y - 55);
    add(counterplaypauseBox);

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
    ducksExisting = children.whereType<DuckSprite>().length;

    // Check if it's time to create new ducks, according to variable interval
    // and add a random number of ducks (mostly 1 or 2), depending on the score
    _lastDuckTime += dt;
    if (_lastDuckTime >= (_duckInterval / (1 + duckHits / 90))) {
      for (int i = 0;
          i < (1 + random.nextDouble() + duckHits / 60).round();
          // i < 1;
          i++) {
        addRandomDuck();
      }
      _lastDuckTime = 0;
    }

    // End game if there max ducks or more, display EndGame overlay
    if (ducksExisting >= maxDucks) {
      pauseEngine();
      overlays.add('EndGame');
    }
  }

  void resetGame() {
    ducksExisting = 0;
    duckHits = 0;
    removeAll(children.whereType<DuckSprite>());
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
    // while overlays are active keep the ducks to third of maxDucks, for fun
    if (overlays.activeOverlays.isNotEmpty && ducksExisting >= maxDucks / 3) {
      return;
    }
    // should never add more ducks if already more than maxDucks on screen...
    if (ducksExisting >= maxDucks) return;

    final x = random.nextDouble() * size.x;
    final y = random.nextDouble() * size.y;
    add(DuckSprite(Vector2(x, y))
      ..movementVector *= (1 + duckHits / 60)
      ..duckRotationSpeed *= (1 + duckHits / 75)
      ..size /= (1 + duckHits / 60));
  }
}
