// ignore_for_file: override_on_non_overriding_member

import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/text.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:fruit_cutting_game/common/widgets/button/back_button.dart';
import 'package:fruit_cutting_game/common/widgets/button/pause_button.dart';
import 'package:fruit_cutting_game/core/configs/assets/app_sfx.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';
import 'package:fruit_cutting_game/presentation/game/widgets/fruit_component.dart';
import 'package:fruit_cutting_game/core/configs/constants/app_configs.dart';
import 'package:fruit_cutting_game/core/configs/constants/app_router.dart';
import 'package:fruit_cutting_game/main_router_game.dart';
import 'package:fruit_cutting_game/presentation/game/widgets/fruit_slice_component.dart';
import 'package:fruit_cutting_game/presentation/game/widgets/slice_component.dart';

/// The main game page where the game play happens.
class GamePage extends Component
    with DragCallbacks, HoverCallbacks, HasGameReference<MainRouterGame> {
  // Random number generator for fruit timings
  final Random random = Random();
  late List<double> fruitsTime; // List to hold the timing for when fruits appear

  // Timing variables
  late double time; // Current elapsed time
  late double countDown; // Countdown timer for the start of the game
  double finishCountDown = 2.0; // Finish countdown duration

  // Game variables
  late int level = 1; // Current game level
  late int mistakeCount; // Number of mistakes made by the player
  late int score; // Player's score
  bool _countdownFinished = false; // Flag to check if countdown is finished

  // UI Components
  TextComponent? _countdownTextComponent; // Component to display countdown
  TextComponent? _mistakeTextComponent; // Component to display mistake count
  TextComponent? _scoreTextComponent; // Component to display score
  TextComponent? _modeTextComponent;

  // Slash effect
  late SliceTrailComponent sliceTrail;
  final List<String> sliceSounds = [AppSfx.sfxChopping, AppSfx.sfxCut];

  /// Called when the component is added to the game.
  @override
  void onMount() {
    super.onMount();

    // Initialize game variables
    fruitsTime = []; // List to store timings for fruit appearances
    countDown = 5; // Start countdown (5 seconds)
    mistakeCount = 0; // Initialize mistake count to zero
    score = 0; // Set initial score to zero
    time = 0; // No time has passed at the start
    _countdownFinished = false; // Countdown has not finished yet
    level = 1;

    generateFruitTimings();

    // Initialize text components for score, countdown, mistakes
    initializeTextComponents();

    sliceTrail = SliceTrailComponent();
    add(sliceTrail);
  }

  void initializeTextComponents() {
    final _scoreTextPaint = TextPaint(
      style: TextStyle(
        fontSize: game.isDesktop ? 32 : 25,
        color: AppColors.white,
        fontWeight: FontWeight.w100,
        fontFamily: 'Insan',
        letterSpacing: 2.0,
      ),
    );

    final _countdownTextPaint = TextPaint(
      style: const TextStyle(
        fontSize: 45,
        color: AppColors.white,
        fontFamily: 'Insan',
        letterSpacing: 2.0,
      ),
    );

    final _mistakeTextPaint = TextPaint(
      style: TextStyle(
        fontSize: game.isDesktop ? 32 : 25,
        color: AppColors.white,
        fontWeight: FontWeight.w100,
        fontFamily: 'Insan',
        letterSpacing: 2.0,
      ),
    );

    final _modeTextPaint = TextPaint(
      style: const TextStyle(
        fontSize: 18,
        color: AppColors.white,
        fontWeight: FontWeight.w100,
        fontFamily: 'Insan',
        letterSpacing: 2.0,
      ),
    );

    // Add game components to the page
    addAll([
      BackButtonCustom(
        onPressed: () {
          removeAll(children);
          game.router.pop();
        },
      ),
      PauseButtonCustom(),
      _countdownTextComponent = TextComponent(
        text: "- Level 1 -",
        size: Vector2.all(50),
        position: Vector2(game.size.x / 2, game.size.y / 2 - 10),
        anchor: Anchor.center,
        textRenderer: _countdownTextPaint,
      ),
      _mistakeTextComponent = TextComponent(
        text: 'Erros: $mistakeCount',
        position: Vector2(game.size.x - 15, 10),
        anchor: Anchor.topRight,
        textRenderer: _mistakeTextPaint,
      ),
      _scoreTextComponent = TextComponent(
        text: 'Pontuação: $score',
        position: Vector2(game.size.x - 15, _mistakeTextComponent!.position.y + 40),
        anchor: Anchor.topRight,
        textRenderer: _scoreTextPaint,
      ),
      _modeTextComponent = TextComponent(
        text: 'Mode ${game.mode == 0 ? 'Easy' : game.mode == 1 ? 'Medium' : 'Hard'}',
        position: Vector2(game.size.x - 15, game.size.y - 15),
        anchor: Anchor.bottomRight,
        textRenderer: _modeTextPaint,
      ),
    ]);
  }

  /// Updates the game state every frame.
  @override
  void update(double dt) {
    super.update(dt); // Call the superclass update

    if (!_countdownFinished) {
      countDown -= dt; // Decrease countdown by the time since last frame

      // Update the countdown text component with the current countdown
      if (countDown < 2) {
        _countdownTextComponent?.text = (countDown.toInt() + 1).toString();
      }

      // Check if the countdown has finished
      if (countDown < 0) {
        _countdownFinished = true; // Set countdown finished flag
      }
    } else if (fruitsTime.isEmpty && !hasFruits()) {
      if (_countdownTextComponent != null && !_countdownTextComponent!.isMounted) {
        _countdownTextComponent?.addToParent(this); // Add to parent if not already on screen
      }

      // Update the countdown text component with the current level or finish countdown
      if (level == 3) {
        _countdownTextComponent?.text = (finishCountDown.toInt() + 1).toString();
      } else {
        _countdownTextComponent?.text = "- Level ${level + 1} -";
      }

      // Check if the finish countdown time has finished
      if (finishCountDown <= 0) {
        gameWin(); // Call the function to indicate a win
      }

      finishCountDown -= dt; // Decrease based on real time

      if (finishCountDown < 0) {
        finishCountDown = 0;
      }
    } else {
      // Remove the countdown text component once finished
      _countdownTextComponent?.removeFromParent();

      time += dt; // Increment time by the time since last frame

      // Spawn fruits whose scheduled time has passed
      fruitsTime.where((element) => element < time).toList().forEach((element) {
        spawnFruit();
        fruitsTime.remove(element);
      });
    }
  }

  void spawnFruit() {
    final gameSize = game.size;
    double posX = random.nextInt(gameSize.x.toInt()).toDouble();
    Vector2 fruitPosition = Vector2(posX, gameSize.y);
    Vector2 velocity = Vector2(0, game.maxVerticalVelocity);

    final randFruit = game.fruits.random();
    add(
      FruitComponent(
        this,
        fruitPosition,
        acceleration: AppConfig.acceleration,
        fruit: randFruit,
        size: AppConfig.shapeSize,
        image: game.images.fromCache(randFruit.image),
        pageSize: gameSize,
        velocity: velocity,
      ),
    );
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  /// Método responsável por processar os eventos de "drag" (mantido para dispositivos de toque)
  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    sliceTrail.addPoint(event.canvasStartPosition);

    componentsAtPoint(event.canvasStartPosition).forEach((element) {
      if (element is FruitComponent && element.canDragOnShape) {
        // Executa os efeitos de corte somente se for desktop (caso mantenha a lógica original)
        if (game.isDesktop) {
          onFruitSliced(sliceTrail);
          element.touchAtPoint(event.canvasStartPosition);
          game.add(FruitSliceComponent(event.canvasStartPosition));
          playRandomSliceSound();
        }
      }
    });
  }

  /// Método para limpar o rastro (trail) quando o drag termina
  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    sliceTrail.clear();
  }

  /// IMPLEMENTAÇÃO NOVA: Processa os eventos de hover para corte automático
  @override
  void onHover(PointerHoverInfo info) {
    final pos = info.eventPosition.global;
    sliceTrail.addPoint(pos);

    componentsAtPoint(pos).forEach((element) {
      if (element is FruitComponent && element.canDragOnShape) {
        // Chama os efeitos de corte
        onFruitSliced(sliceTrail);
        element.touchAtPoint(pos);
        game.add(FruitSliceComponent(pos));
        playRandomSliceSound();
      }
    });
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    _countdownTextComponent?.position = game.size / 2;
    _mistakeTextComponent?.position = Vector2(game.size.x - 15, 10);
    _scoreTextComponent?.position =
        Vector2(game.size.x - 15, _mistakeTextComponent!.position.y + 40);
    _modeTextComponent?.position = Vector2(game.size.x - 15, game.size.y - 15);
  }

  bool hasFruits() {
    return children.any((component) => component is FruitComponent);
  }

  /// Navega para a tela de Game Over.
  void gameOver() {
    FlameAudio.bgm.stop();
    game.saveScore(score);
    game.router.pushNamed(AppRouter.gameOver);
  }

  void gameWin() {
    if (level < 3) {
      level++;
      resetLevel();
    } else {
      FlameAudio.bgm.stop();
      game.saveScore(score);
      game.router.pushNamed(AppRouter.gameVictory);
    }
  }

  void resetLevel() {
    fruitsTime.clear();
    time = 0;
    countDown = 3;
    finishCountDown = 2.0;
    _countdownFinished = false;
    generateFruitTimings();
  }

  /// Incrementa a pontuação do jogador e atualiza o display.
  void addScore() {
    score++;
    _scoreTextComponent?.text = 'Score: $score';
  }

  /// Incrementa o contador de erros e atualiza o display.
  void addMistake() {
    mistakeCount++;
    _mistakeTextComponent?.text = 'Mistake: $mistakeCount';
    if (mistakeCount >= 999999) {
      gameOver();
    }
  }

  /// Aplica efeito visual ao rastro (trail) de corte.
  void onFruitSliced(SliceTrailComponent sliceTrailComponent) {
    sliceTrailComponent.changeColor();
  }

  /// Toca um som de corte selecionado aleatoriamente.
  void playRandomSliceSound() {
    String selectedSound = sliceSounds[random.nextInt(sliceSounds.length)];
    FlameAudio.play(selectedSound, volume: 0.5);
  }

  void generateFruitTimings() {
    fruitsTime.clear();
    double initTime = 0;

    int fruitCount = getFruitCount(level, game.mode);
    double minInterval = getMinInterval(level, game.mode);

    for (int i = 0; i < fruitCount; i++) {
      if (i != 0) initTime = fruitsTime.last;
      double milliSecondTime = random.nextInt(100) / 100;
      double componentTime = random.nextInt(1) * minInterval + milliSecondTime + initTime;
      fruitsTime.add(componentTime);
    }
  }

  int getFruitCount(int level, int mode) {
    const List<List<int>> fruitCounts = [
      [15, 20, 30], // Level 1
      [20, 30, 40], // Level 2
      [30, 40, 60], // Level 3
    ];
    return fruitCounts[level - 1][mode];
  }

  double getMinInterval(int level, int mode) {
    const List<List<double>> minIntervals = [
      [1.5, 1.5, 1.2], // Level 1
      [1.2, 1.0, 0.8], // Level 2
      [0.8, 0.6, 0.5], // Level 3
    ];
    return minIntervals[level - 1][mode];
  }
}
