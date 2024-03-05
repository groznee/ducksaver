import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame/particles.dart';

import 'package:flame_audio/flame_audio.dart';

import 'package:flutter/material.dart';

import 'my_game.dart';

class DuckSprite extends SpriteComponent
    with TapCallbacks, HasGameRef<MyGame>, CollisionCallbacks {
  double duckRotationSpeed = 0.90;
  double duckTranslationSpeed = 200;
  double duckSize = 375.0;
  Random random = Random();
  double duckeffectsTime = 0.4;

  late final PolygonHitbox duckhitbox;
  var beingremoved = false;
  var ducksound = 'quack_2.mp3';

  List<String> pngAssets = [
    'duck (1).png',
    'duck (2).png',
    'duck (3).png',
    'duck (4).png',
  ];

  List<String> mp3Assets = [
    'quack_1.mp3',
    'quack_2.mp3',
    'quack_3.mp3',
    'quack_4.mp3',
    'quack_5.mp3',
    'quack_6.mp3',
    'quack_7.mp3',
  ];

  Vector2 movementVector = Vector2.zero();

  DuckSprite(Vector2 position)
      : super(
          position: position,
          anchor: Anchor.center,
        ) {
    size = Vector2.all(duckSize);
    // random values between -duckTranslationSpeed and duckTranslationSpeed
    movementVector = Vector2(
      random.nextDouble() * duckTranslationSpeed - duckTranslationSpeed,
      random.nextDouble() * duckTranslationSpeed - duckTranslationSpeed,
    );
  }

  @override
  // evertyhing is mupltiplied by dt to make it framerate independent, dt is the time since last frame
  // so for higher framerate, less time passes and the change for each frame is smaller
  void update(double dt) {
    super.update(dt);

    angle += duckRotationSpeed * dt;
    angle %= 2 * pi;

    // Failsafe to check if the (center of a) duck is trying to escape the screen
    if (position.x <= 0 || position.x >= gameRef.size.x) {
      movementVector.x = -movementVector.x; // Reverse x direction
    }
    if (position.y <= 0 || position.y >= gameRef.size.y) {
      movementVector.y = -movementVector.y; // Reverse y direction
    }

    position += movementVector * dt;

    //check if the hitbox is to be drawn
    duckhitbox.renderShape = gameRef.duckHitBoxDrawn;
  }

  @override
  void onTapDown(TapDownEvent event) {
    event.continuePropagation = true;

    //55 offset because hitbox is offset on X ordinate by 55
    //to be honest all of this is a bit of a hack, but it works
    if (duckhitbox.containsLocalPoint(event.localPosition - Vector2(55, 0))) {
      FlameAudio.play(ducksound);
      if (!beingremoved) {
        beingremoved = true;
        gameRef.duckHits++;
      }

      // create a color list for the particles, from Colors.red in this case
      // non accent swatches have a value at [50], but we don't need that
      List<Color> colors = [];
      for (int i = 100; i <= 900; i += 100) {
        colors.add(Colors.red[i]!);
      }

      Color randomMaterialColor() {
        return colors[random.nextInt(colors.length)];
      }

      Particle randomMovingParticles() {
        return Particle.generate(
          count: 18,
          generator: (i) => MovingParticle(
            to: (Vector2.random() - Vector2.random())..multiply(size),
            child: CircleParticle(
              radius: 3 + random.nextDouble() * 9,
              paint: Paint()..color = randomMaterialColor(),
            ),
          ),
        );
      }

      add(
        ParticleSystemComponent(
          particle: TranslatedParticle(
            lifespan: duckeffectsTime,
            offset: size / 2,
            child: randomMovingParticles(),
          ),
        ),
      );
      add(OpacityEffect.fadeOut(EffectController(
        duration: duckeffectsTime,
      )));
      add(RemoveEffect(delay: duckeffectsTime));
      event.handled = true;
    }
  }

  // this effect can be here or on onLoad (in this case!), onMount is run each
  // time the component is added to the game, and onLoad is run only once
  // @override
  // void onMount() {
  //   //add fade in effect
  //   add(OpacityEffect.to(0, EffectController(duration: 0)));
  //   add(OpacityEffect.fadeIn(EffectController(
  //     duration: duckeffectsTime,
  //   )));
  //   super.onMount();
  // }

  @override
  Future<void> onLoad() async {
    int randomIndex = random.nextInt(pngAssets.length);
    sprite = await Sprite.load(pngAssets[randomIndex]);
    ducksound = mp3Assets[randomIndex];
    FlameAudio.play(ducksound);

    duckhitbox = PolygonHitbox.relative(
      [
        Vector2(0.0, 1.0),
        Vector2(0.66, 0.66),
        Vector2(0.66, -0.66),
        Vector2(0.0, -1.0),
        Vector2(-0.66, -0.66),
        Vector2(-0.66, 0.66),
      ],
      parentSize: size,
    );

    final hitboxPaint = BasicPalette.white.paint()
      ..style = PaintingStyle.stroke;

    add(
      duckhitbox
        ..paint = hitboxPaint
        ..renderShape = gameRef.duckHitBoxDrawn,
    );

    add(OpacityEffect.to(0, EffectController(duration: 0)));
    add(OpacityEffect.fadeIn(EffectController(
      duration: duckeffectsTime,
    )));

    super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is ScreenHitbox) {
      movementVector.negate();
      FlameAudio.play('quack_bounce.mp3', volume: 0.5);
    }
    super.onCollisionStart(intersectionPoints, other);
    // flipHorizontally();
    // flipVertically();
  }
}
