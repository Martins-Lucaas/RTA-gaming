import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/rendering.dart';
import 'package:flame/text.dart';
import 'package:flutter/foundation.dart';
import 'package:fruit_cutting_game/core/configs/constants/app_router.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';
import 'package:fruit_cutting_game/main_router_game.dart';
import 'package:fruit_cutting_game/presentation/game/game.dart';
import 'package:intl/intl.dart';

/// Esta classe representa a rota para a tela de Fim de Jogo.
class GameOverRoute extends Route {
  /// Construtor de GameOverRoute, definindo que a tela exibida será a GameOverPage.
  GameOverRoute() : super(GameOverPage.new, transparent: true);

  /// Quando essa rota é acionada, para o tempo do jogo e aplica um efeito cinza no fundo.
  @override
  void onPush(Route? previousRoute) {
    previousRoute!
      ..stopTime() // Para o tempo do jogo.
      ..addRenderEffect(
        // Adiciona um efeito visual ao fundo.
        PaintDecorator.grayscale(opacity: 0.5) // Torna o fundo cinza.
          ..addBlur(3.0), // Adiciona um efeito de desfoque.
      );
  }

  /// Quando essa rota é removida, retoma o tempo do jogo e remove os efeitos.
  @override
  void onPop(Route nextRoute) {
    // Encontra as rotas-filho que são do tipo GamePage.
    final routeChildren = nextRoute.children.whereType<GamePage>();
    if (routeChildren.isNotEmpty) {
      final gamePage = routeChildren.first; // Obtém a primeira GamePage.
      gamePage.removeAll(gamePage.children); // Remove todos os componentes da GamePage.
    }

    nextRoute
      ..resumeTime() // Retoma o tempo do jogo.
      ..removeRenderEffect(); // Remove os efeitos visuais.
  }
}

/// Esta classe representa a tela de Fim de Jogo exibida após o término do jogo.
class GameOverPage extends Component with TapCallbacks, HasGameReference<MainRouterGame> {
  late TextComponent _textComponent; // Componente de texto para exibir a mensagem de fim de jogo.
  late TextComponent _textTimeComponent;
  late TextComponent _textScoreComponent;
  late TextComponent _textNewGameComponent;
  late TextComponent _textGameModeComponent;

  // O botão "Ranking" foi removido.

  final String timezone = 'UTC+7';

  /// Carrega os componentes para a tela de Fim de Jogo.
  @override
  FutureOr<void> onLoad() {
    final textTitlePaint = TextPaint(
      style: const TextStyle(
        fontSize: 60,
        color: AppColors.white,
        fontFamily: 'Insan',
        letterSpacing: 2.0,
      ),
    );

    final textTimePaint = TextPaint(
      style: TextStyle(
        fontSize: game.isDesktop ? 25 : 18,
        color: AppColors.white,
        fontFamily: 'Insan',
        letterSpacing: 2.0,
      ),
    );

    final textPaint = TextPaint(
      style: TextStyle(
        fontSize: game.isDesktop ? 18 : 12,
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

    // Não cria nem adiciona o botão "Ranking".

    final flameGame = findGame()!; // Obtém a instância atual do jogo.

    // Adiciona os componentes de texto para exibir as mensagens.
    addAll(
      [
        _textComponent = TextComponent(
          text: 'Fim de Jogo', // A mensagem a ser exibida.
          position: flameGame.canvasSize / 2, // Centraliza o texto na tela.
          anchor: Anchor.center, // Define o ponto de ancoragem como o centro.
          children: [
            // Adiciona um efeito de escalonamento ao texto.
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
        _textNewGameComponent = TextComponent(
          text: "Clique em qualquer lugar para iniciar um novo jogo",
          position: flameGame.canvasSize / 2,
          anchor: game.isDesktop ? Anchor.centerRight : Anchor.center,
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
          anchor: game.isDesktop ? Anchor.centerLeft : Anchor.center,
          textRenderer: textPaint,
        ),
      ],
    );
  }

  /// Chamado quando o jogo é redimensionado; atualiza a posição dos textos para permanecerem centralizados.
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _textComponent.position = Vector2(game.size.x / 2, game.size.y / 2 - 70);
    _textTimeComponent.position = Vector2(15, 20);
    _textScoreComponent.position = Vector2(game.size.x / 2, game.size.y / 2 + 25);
    _textScoreComponent.text = 'Pontuação: ${game.getScore()}';

    // Linha referente ao botão "Ranking" removida:
    // _buttonLeaderboard.position = Vector2(game.size.x / 2, game.size.y / 2 + 110);

    _textNewGameComponent.position = game.isDesktop
        ? Vector2(game.size.x - 15, game.size.y - 15)
        : Vector2(game.size.x / 2, game.size.y - 15);
    _textGameModeComponent.position =
        game.isDesktop ? Vector2(15, game.size.y - 15) : Vector2(game.size.x / 2, game.size.y - 30);
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

  /// Trata os eventos de toque; ao tocar, navega para a página inicial.
  @override
  void onTapUp(TapUpEvent event) {
    game.router
      ..pop() // Volta para a rota anterior.
      ..pushNamed(AppRouter.homePage, replace: true); // Abre a rota da página inicial.
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
