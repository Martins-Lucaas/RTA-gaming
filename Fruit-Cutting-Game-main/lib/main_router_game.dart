import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame_audio/flame_audio.dart';

import 'package:fruit_cutting_game/core/configs/assets/app_images.dart';
import 'package:fruit_cutting_game/core/configs/assets/app_sfx.dart';
import 'package:fruit_cutting_game/core/configs/constants/app_configs.dart';
import 'package:fruit_cutting_game/core/configs/constants/app_router.dart';
import 'package:fruit_cutting_game/data/models/fruit_model.dart';
import 'package:fruit_cutting_game/presentation/game/game.dart';
import 'package:fruit_cutting_game/presentation/game_over/game_over.dart';
import 'package:fruit_cutting_game/presentation/game_pause/game_pause.dart';
import 'package:fruit_cutting_game/presentation/game_victory/game_victory.dart';
import 'package:fruit_cutting_game/presentation/home/home.dart';

/// Classe principal do jogo que estende FlameGame
class MainRouterGame extends FlameGame with KeyboardEvents {
  final Random random = Random();
  late final RouterComponent router;
  late double maxVerticalVelocity;

  // Lista de frutas disponíveis no jogo
  final List<FruitModel> fruits = [
    FruitModel(image: AppImages.apple),
    FruitModel(image: AppImages.banana),
    FruitModel(image: AppImages.kiwi),
    FruitModel(image: AppImages.orange),
    FruitModel(image: AppImages.peach),
    FruitModel(image: AppImages.pineapple),
    FruitModel(image: AppImages.watermelon),
    FruitModel(image: AppImages.cherry),
    FruitModel(image: AppImages.bomb, isBomb: true),
    FruitModel(image: AppImages.flame, isBomb: true),
  ];

  void startBgmMusic() {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play(AppSfx.musicBG, volume: 0.3);
  }

  bool isDesktop = false; // Estado atual da tela

  int score = 0; // Pontuação atual do jogador

  /// Retorna a pontuação atual.
  int getScore() {
    return score;
  }

  /// Salva a pontuação informada.
  void saveScore(int scoreInput) {
    score = scoreInput;
  }

  int mode = 0; // Modo atual do jogo (0, 1, 2, etc.)

  /// Retorna o modo atual do jogo.
  int getMode() {
    return mode;
  }

  /// Salva o modo informado.
  void saveMode(int modeInput) {
    mode = modeInput;
  }

  @override
  void onLoad() async {
    super.onLoad();

    for (final fruit in fruits) {
      await images.load(fruit.image);
    }

    await images.load(AppImages.homeBG);

    addAll(
      [
        ParallaxComponent(
          parallax: Parallax(
            [
              await ParallaxLayer.load(
                ParallaxImageData(AppImages.homeBG),
              ),
            ],
          ),
        ),
        // Configura o router para navegação entre as telas do jogo.
        router = RouterComponent(
          initialRoute: AppRouter.homePage,
          routes: {
            AppRouter.homePage: Route(HomePage.new),
            AppRouter.gamePage: Route(GamePage.new),
            AppRouter.gameVictory: VictoryRoute(),
            AppRouter.gameOver: GameOverRoute(),
            AppRouter.gamePause: PauseRoute(),
          },
        )
      ],
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    getMaxVerticalVelocity(size);
  }

  /// Calcula a velocidade vertical máxima baseada no tamanho do jogo.
  void getMaxVerticalVelocity(Vector2 size) {
    // Fórmula para calcular a velocidade vertical máxima.
    // Ajusta conforme o tamanho do objeto.
    maxVerticalVelocity = sqrt(2 *
        (AppConfig.gravity.abs() + AppConfig.acceleration.abs()) *
        (size.y - AppConfig.objSize * 2));
  }
}
