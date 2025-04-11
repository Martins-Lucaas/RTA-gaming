import 'dart:ui';
import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart'
    hide Game; // Oculta a classe Game para evitar conflitos de nomenclatura.
import 'package:flame/rendering.dart';
import 'package:flame/text.dart';
import 'package:flutter/foundation.dart';
import 'package:fruit_cutting_game/common/helpers/app_save_action.dart';
import 'package:fruit_cutting_game/common/widgets/button/rounded_button.dart';
import 'package:fruit_cutting_game/core/configs/constants/app_router.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';
import 'package:fruit_cutting_game/main_router_game.dart';
import 'package:intl/intl.dart';

/// Esta classe representa a rota para a tela de vitória do jogo.
class VictoryRoute extends Route {
  /// Construtor da VictoryRoute, define que será exibida a GameVictoryPage.
  VictoryRoute() : super(GameVictoryPage.new, transparent: true);

  /// Quando essa rota é acionada (aberta), para o tempo do jogo e aplica um efeito de cinza no fundo.
  @override
  void onPush(Route? previousRoute) {
    previousRoute!
      ..stopTime() // Para o tempo do jogo.
      ..addRenderEffect(
        // Adiciona um efeito visual ao fundo.
        PaintDecorator.grayscale(opacity: 0.5) // Torna o fundo cinza.
          ..addBlur(3.0), // Adiciona um efeito de desfoque ao fundo.
      );
  }

  /// Quando essa rota for fechada, retoma o tempo do jogo e remove os efeitos do fundo.
  @override
  void onPop(Route nextRoute) {
    nextRoute
      ..resumeTime() // Retoma o tempo do jogo.
      ..removeRenderEffect(); // Remove os efeitos visuais do fundo.
  }
}

/// Esta classe representa a tela de vitória exibida quando o jogo é vencido.
class GameVictoryPage extends Component with TapCallbacks, HasGameReference<MainRouterGame> {
  late TextComponent _textComponent; // Componente de texto para exibir a mensagem "VITÓRIA".
  late TextComponent _textTimeComponent;
  late TextComponent _textScoreComponent;
  late TextComponent _textLeaderboardComponent;
  late TextComponent _textGameModeComponent;

  late RoundedButton _buttonNewGameComponent;

  final String timezone = 'UTC+7';

  /// Carrega os componentes para a tela de vitória.
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
          ..pop() // Volta para a rota anterior.
          ..pushNamed(AppRouter.homePage, replace: true); // Abre a rota da página inicial.
      },
    );

    add(_buttonNewGameComponent);

    final flameGame = findGame()!; // Obtém a instância atual do jogo.

    // Adiciona os componentes de texto para exibir as mensagens.
    addAll(
      [
        _textComponent = TextComponent(
          text: 'VITÓRIA', // A mensagem a ser exibida quando o jogo é vencido.
          position: flameGame.canvasSize / 2, // Centraliza o texto na tela.
          anchor: Anchor.center, // Define o ponto de ancoragem como o centro do texto.
          children: [
            // Adiciona um efeito de escalonamento ao texto para fazê-lo pulsar.
            ScaleEffect.to(
              Vector2.all(1.1), // Aumenta o texto para 110%.
              EffectController(
                duration: 0.3, // Duração do efeito de escalonamento.
                alternate: true, // Faz o efeito ir e voltar.
                infinite: true, // Repete o efeito indefinidamente.
              ),
            ),
          ],
          textRenderer: textTitlePaint,
        ),
        _textTimeComponent = TextComponent(
          text: "", // A mensagem a ser exibida.
          position: flameGame.canvasSize / 2, // Centraliza o texto na tela.
          anchor: Anchor.centerLeft, // Define o ponto de ancoragem para a esquerda central.
          textRenderer: textTimePaint,
        ),
        _textLeaderboardComponent = TextComponent(
          text: "Clique em qualquer lugar para salvar as classificações",
          position: flameGame.canvasSize / 2,
          anchor: Anchor.centerRight,
          textRenderer: textPaint,
        ),
        _textScoreComponent = TextComponent(
          text: 'Pontuação: ',
          position: flameGame.canvasSize / 2,
          anchor: Anchor.center,
          textRenderer: textScorePaint,
        ),
        _textGameModeComponent = TextComponent(
          text: "Modo: ${game.mode == 0 ? 'Fácil' : game.mode == 1 ? 'Médio' : 'Difícil'}",
          position: flameGame.canvasSize / 2,
          anchor: Anchor.centerLeft,
          textRenderer: textPaint,
        ),
      ],
    );
  }

  /// Chamado quando o jogo é redimensionado; atualiza a posição dos textos para permanecer centralizada.
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _textComponent.position = Vector2(game.size.x / 2, game.size.y / 2 - 70);
    _textTimeComponent.position = Vector2(15, 20);
    _textScoreComponent.position = Vector2(game.size.x / 2, game.size.y / 2 + 25);
    _buttonNewGameComponent.position = Vector2(game.size.x / 2, game.size.y / 2 + 110);
    _textLeaderboardComponent.position = Vector2(game.size.x - 15, game.size.y - 15);
    _textGameModeComponent.position = Vector2(15, game.size.y - 15);

    _textScoreComponent.text = 'Pontuação: ${game.getScore()}';
  }

  /// Retorna sempre true, indicando que este componente pode receber eventos de toque.
  @override
  bool containsLocalPoint(Vector2 point) {
    return true; // Aceita todos os eventos de toque.
  }

  @override
  void update(double dt) {
    super.update(dt);

    DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));
    String formattedTime = DateFormat('MM/dd/yyyy HH:mm').format(now);

    if (_textTimeComponent.text != '$formattedTime ($timezone)') {
      _textTimeComponent.text = '$formattedTime ($timezone)';
    }
  }

  /// Trata os eventos de toque; ao liberar o toque, salva a imagem e cria uma issue.
  @override
  Future<void> onTapUp(TapUpEvent event) async {
    await captureAndSaveImage();
    final GitHubService gitHubService = GitHubService(
      time: _textTimeComponent.text,
      score: game.getScore().toString(),
      mode: game.mode.toString(),
      win: true,
    );
    gitHubService.createIssue();
  }

  Future<void> captureAndSaveImage() async {
    try {
      final PictureRecorder recorder = PictureRecorder();
      final Rect rect = Rect.fromLTWH(0.0, 0.0, game.size.x, game.size.y);
      final Canvas c = Canvas(recorder, rect);

      game.render(c);

      final Image image =
          await recorder.endRecording().toImage(game.size.x.toInt(), game.size.y.toInt());
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}
