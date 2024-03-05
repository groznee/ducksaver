import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

import 'my_game.dart';
// import 'ducksprite.dart';

class BottomRightTextBox extends TextBoxComponent
    with TapCallbacks, HasGameRef<MyGame> {
  BottomRightTextBox(
    String text, {
    super.align = Anchor.center,
    super.size,
    double timePerChar = 0.0,
    double margins = 0,
    double sizeOfFont = 28,
    FontWeight weightOfFont = FontWeight.w900,
  }) : super(
          text: text,
          textRenderer: TextPaint(
              style: TextStyle(
                  fontSize: sizeOfFont,
                  fontWeight: weightOfFont,
                  color: BasicPalette.white.color)),
          boxConfig: TextBoxConfig(),
          // priority: 9000, // high priority ensures boxes are on top of the ducks
        );

  @override
  void onTapDown(TapDownEvent event) {
    if (gameRef.paused == false) {
      gameRef.pauseEngine();
    } else {
      gameRef.resumeEngine();
    }

    event.handled = true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    text = gameRef.duckHits.toString();
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(
        rect, Paint()..color = const Color.fromRGBO(191, 54, 12, 1));
    super.render(canvas);
  }
}

//these were used in development and for learning purposes (inheritance)
// class DisplayHitboxesBox extends BottomRightTextBox {
//   DisplayHitboxesBox(String text, {required Vector2 size})
//       : super(text, size: size, sizeOfFont: 12, weightOfFont: FontWeight.w400);

//   @override
//   void onTapDown(TapDownEvent event) {
//     gameRef.duckHitBoxDrawn = !gameRef.duckHitBoxDrawn;
//     event.handled = true;
//   }
// }

// class DucksHitCounterBox extends BottomRightTextBox {
//   DucksHitCounterBox(String text, {required Vector2 size})
//       : super(text, size: size);

//   @override
//   void onTapDown(TapDownEvent event) {
//     gameRef.removeAll(gameRef.children.whereType<DuckSprite>());
//     // double dot notation: you can access the created DuckSprite's fields
//     // without keeping a reference to the object somewhere, pretty clean
//     gameRef.add(DuckSprite(gameRef.size / 2)
//       ..movementVector = Vector2(0, 0)
//       ..duckRotationSpeed = 0
//       ..size = Vector2.all(500));
//     event.handled = true;
//   }
// }
