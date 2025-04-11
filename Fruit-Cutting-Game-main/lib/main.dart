import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart' hide Game;
import 'package:fruit_cutting_game/main_router_game.dart';
import 'web_title_switcher_stub.dart' if (dart.library.html) 'web_title_switcher_web.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Flame.device.fullScreen();
  Flame.device.setLandscape();

  runApp(
    WebTitleSwitcher(
      child: GameWidget(
        game: MainRouterGame(),
      ),
    ),
  );
}
