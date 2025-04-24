// ignore_for_file: unused_import

import 'dart:ui';
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart' hide Game;
import 'package:flame/rendering.dart';
import 'package:flame/text.dart';
import 'package:flutter/foundation.dart';
import 'package:fruit_cutting_game/common/widgets/button/rounded_button.dart';
import 'package:fruit_cutting_game/core/configs/constants/app_router.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';
import 'package:fruit_cutting_game/main_router_game.dart';
import 'package:intl/intl.dart';

class VictoryRoute extends Route {
  VictoryRoute() : super(GameVictoryPage.new, transparent: true);

  @override
  void onPush(Route? previousRoute) {
    previousRoute!
      ..stopTime()
      ..addRenderEffect(
        PaintDecorator.grayscale(opacity: 0.5)..addBlur(3.0),
      );
  }

  @override
  void onPop(Route nextRoute) {
    nextRoute
      ..resumeTime()
      ..removeRenderEffect();
  }
}

class GameVictoryPage extends Component with TapCallbacks, HasGameReference<MainRouterGame> {
  late TextComponent _textComponent;
  late TextComponent _textTimeComponent;
  late TextComponent _textScoreComponent;
  late TextComponent _textGameModeComponent;
  late RoundedButton _buttonNewGameComponent;

  final String timezone = 'UTC-3';

  @override
  Future<void> onLoad() async {
    final textTitlePaint = TextPaint(
      style: const TextStyle(
        fontSize: 80,
        color: AppColors.white,
        fontFamily: 'Marshmallow',
        letterSpacing: 3.0,
      ),
    );

    final textPaint = TextPaint(
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.white,
        fontFamily: 'Insan',
        letterSpacing: 2.0,
      ),
    );

    final textTimePaint = TextPaint(
      style: const TextStyle(
        fontSize: 25,
        color: AppColors.white,
        fontFamily: 'Insan',
        letterSpacing: 2.0,
      ),
    );

    final textScorePaint = TextPaint(
      style: const TextStyle(
        fontSize: 35,
        color: AppColors.white,
        fontFamily: 'Insan',
        letterSpacing: 2.0,
      ),
    );

    _buttonNewGameComponent = RoundedButton(
      bgColor: AppColors.githubColor,
      borderColor: AppColors.blue,
      text: "Novo Jogo",
      anchor: Anchor.center,
      onPressed: () {
        game.router
          ..pop()
          ..pushNamed(AppRouter.homePage, replace: true);
      },
    );

    final flameGame = findGame()!;

    addAll([
      _textComponent = TextComponent(
        text: 'VITÓRIA',
        position: flameGame.canvasSize / 2,
        anchor: Anchor.center,
        children: [
          ScaleEffect.to(
            Vector2.all(1.1),
            EffectController(duration: 0.3, alternate: true, infinite: true),
          ),
        ],
        textRenderer: textTitlePaint,
      ),
      _textTimeComponent = TextComponent(
        text: "",
        position: Vector2(15, 20),
        anchor: Anchor.topLeft,
        textRenderer: textTimePaint,
      ),
      _textScoreComponent = TextComponent(
        text: 'Pontuação: ${game.getScore()}',
        position: Vector2(flameGame.size.x / 2, flameGame.size.y / 2 + 25),
        anchor: Anchor.center,
        textRenderer: textScorePaint,
      ),
      _textGameModeComponent = TextComponent(
        text: "Modo: ${game.mode == 0 ? 'Fácil' : game.mode == 1 ? 'Médio' : 'Difícil'}",
        position: Vector2(15, flameGame.size.y - 15),
        anchor: Anchor.bottomLeft,
        textRenderer: textPaint,
      ),
      _buttonNewGameComponent,
    ]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _textComponent.position = Vector2(size.x / 2, size.y / 2 - 70);
    _textScoreComponent.position = Vector2(size.x / 2, size.y / 2 + 25);
    _buttonNewGameComponent.position = Vector2(size.x / 2, size.y / 2 + 110);
    _textTimeComponent.position = Vector2(15, 20);
    _textGameModeComponent.position = Vector2(15, size.y - 15);
    _textScoreComponent.text = 'Pontuação: ${game.getScore()}';
  }

  @override
  void update(double dt) {
    super.update(dt);
    DateTime now = DateTime.now().toUtc().subtract(const Duration(hours: 3));
    String formattedTime = DateFormat('dd/MM/yyyy HH:mm').format(now);
    String displayTime = '$formattedTime ($timezone)';
    if (_textTimeComponent.text != displayTime) {
      _textTimeComponent.text = displayTime;
    }
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onTapUp(TapUpEvent event) {
    // Nenhuma ação extra ao toque além do botão
  }
}
