import 'package:flame/game.dart';

import 'package:flutter/material.dart';

import 'my_game.dart';
import 'overlays_end.dart';
import 'overlays_menu.dart';

// without overlays, simple GameWidget and no need for references
// GameWidget is a widget we use to insert the FlameGame to the Widget tree
// void main() {
//   runApp(
//     GameWidget(
//       game: MyGame(),
//     ),
//   );
// }

//for overlays we need to pass the FlameGame reference, MyGame here is arbitrary
// name defined in my_game.dart (just extends FlameGame, i.e. is a FlameGame)
final game = MyGame();
void main() {
  runApp(
    GameWidget<MyGame>(
      game: game,
      overlayBuilderMap: {
        'MainMenu': (_, game) => MainMenu(game: game),
        'EndGame': (_, game) => EndGame(game: game),
      },
      initialActiveOverlays: const ['MainMenu'],
    ),
  );
}
