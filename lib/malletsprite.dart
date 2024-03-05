import 'dart:math';

import 'package:flame/effects.dart';
import 'package:flame/components.dart';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/animation.dart';

import 'my_game.dart';

class MalletSprite extends SpriteComponent with HasGameRef<MyGame> {
  double malletSize = 142.5;
  double malletOrientation = 1; //1 for right, -1 for left
  Random random = Random();
  bool isHit; // parameter is required, no default value needed
  double malletEffectsTime = 0.15;
  Curve malletCurve = Curves.easeOutBack;
  double malletAngle = pi / 2; //default mallet swing is 90°
  // double malletAngle = 1.571; //90° in radians
  var malletsound = 'mallet_2.mp3';

  List<String> pngAssets = [
    'mallet (1).png',
    'mallet (2).png',
    'mallet (3).png',
  ];

  List<String> mp3Assets = [
    'mallet_1.mp3',
    'mallet_2.mp3',
    'mallet_3.mp3',
    'mallet_4.mp3',
  ];

  MalletSprite(Vector2 position, Curve curve, {required this.isHit})
      : super(
          position: position,
          anchor: Anchor.center,
        ) {
    malletCurve = curve;
    malletOrientation = position.x > gameRef.size.x / 2 ? -1 : 1;
    Vector2 offset =
        Vector2(malletOrientation * malletSize * 0.3, malletSize * 0.15);
    malletAngle = malletOrientation * malletAngle;
    if (!isHit) malletAngle /= 2;
    position = position - offset;
    size = Vector2.all(malletSize);
    super.position = position;
  }

  @override
  void onMount() {
    add(OpacityEffect.fadeOut(EffectController(
      duration: malletEffectsTime,
    )));
    add(RotateEffect.by(malletAngle,
        EffectController(curve: malletCurve, duration: malletEffectsTime)));
    add(RemoveEffect(delay: malletEffectsTime * 2));
    super.onMount();
  }

  @override
  Future<void> onLoad() async {
    int randomIndex = random.nextInt(pngAssets.length);
    sprite = await Sprite.load(pngAssets[randomIndex]);
    malletsound = mp3Assets[randomIndex];
    if (isHit) {
      FlameAudio.play(malletsound);
    } else {
      FlameAudio.play('mallet_whoosh.mp3');
    }

    add(OpacityEffect.to(0, EffectController(duration: 0)));
    add(OpacityEffect.fadeIn(EffectController(
      duration: malletEffectsTime,
    )));
    super.onLoad();
  }
}
