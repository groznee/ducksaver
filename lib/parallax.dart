import 'dart:math';

import 'package:flame/parallax.dart';
import 'package:flame/components.dart';

import 'package:flutter/material.dart';

import 'my_game.dart';

class MyParallaxComponent extends ParallaxComponent<MyGame> {
  List<String> paraBacks = [
    'parallax b (1).png',
    'parallax b (2).png',
    'parallax b (3).png',
  ];

  List<String> paraFronts = [
    'parallax f (1).png',
    'parallax f (2).png',
    'parallax f (3).png',
  ];

  final random = Random();

  @override
  Future<void> onLoad() async {
    parallax = await gameRef.loadParallax(
      [
        ParallaxImageData(paraBacks[random.nextInt(paraBacks.length)]),
        ParallaxImageData(paraFronts[random.nextInt(paraFronts.length)]),
      ],
      repeat: ImageRepeat.repeatX,
      baseVelocity: Vector2(5, 0),
      velocityMultiplierDelta: Vector2(1.5, 0),
      fill: LayerFill.height,
    );
  }
}
