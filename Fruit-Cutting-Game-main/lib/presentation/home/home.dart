// ignore_for_file: unused_field

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:fruit_cutting_game/common/widgets/button/rounded_button.dart';
import 'package:fruit_cutting_game/common/widgets/text/simple_center_text.dart';
import 'package:fruit_cutting_game/core/configs/assets/app_images.dart';
import 'package:fruit_cutting_game/core/configs/constants/app_router.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';
import 'package:fruit_cutting_game/main_router_game.dart';
import 'package:fruit_cutting_game/presentation/home/widgets/game_mode_component.dart';
import 'package:fruit_cutting_game/presentation/home/widgets/tutorial_fruit_component.dart';

/// Tela inicial (HomePage) do jogo, exibindo as frutas, botões e regras.
class HomePage extends Component with HasGameReference<MainRouterGame> {
  // Botão principal para iniciar o jogo
  late final RoundedButton _button;

  // Componentes de texto para as regras e instruções
  late final SimpleCenterText _tutorialRuleLose1Component;
  late final SimpleCenterText _tutorialRuleLose2Component;
  late final SimpleCenterText _tutorialRuleScore1Component;
  late final SimpleCenterText _tutorialRuleScore2Component;

  // Componentes de texto para listas de frutas
  late final TextComponent _ediblesTextComponent;
  late final TextComponent _bombTextComponent;

  // Componente para escolher o modo de jogo
  late final InteractiveButtonComponent _gameModeComponent;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final textTitlePaint = TextPaint(
      style: const TextStyle(
        fontSize: 26,
        color: AppColors.white,
        fontFamily: 'Insan',
        letterSpacing: 2.0,
        fontWeight: FontWeight.bold,
      ),
    );

    // Se a tela for grande o suficiente (eixo X maior que 600 e eixo Y maior que 400),
    // ajusta a interface para "modo desktop".
    if (game.size.x > 600 && game.size.y > 400) {
      addAll([
        _ediblesTextComponent = TextComponent(
          text: 'Comestíveis',
          position: Vector2(45, 10),
          anchor: Anchor.topLeft,
          textRenderer: textTitlePaint,
        ),
        TutorialFruitsListComponent(
          isLeft: true,
          fruits: [
            TutorialFruitComponent(text: 'Maçã', imagePath: AppImages.apple, isLeft: true),
            TutorialFruitComponent(text: 'Banana', imagePath: AppImages.banana, isLeft: true),
            TutorialFruitComponent(text: 'Cereja', imagePath: AppImages.cherry, isLeft: true),
            TutorialFruitComponent(text: 'Kiwi', imagePath: AppImages.kiwi, isLeft: true),
            TutorialFruitComponent(text: 'Laranja', imagePath: AppImages.orange, isLeft: true),
          ],
        )..position = Vector2(0, 50),
        _bombTextComponent = TextComponent(
          text: 'Bomba',
          position: Vector2(game.size.x - 45, 10),
          anchor: Anchor.topRight,
          textRenderer: textTitlePaint,
        ),
        TutorialFruitsListComponent(
          isLeft: false,
          fruits: [
            TutorialFruitComponent(text: 'Bomba', imagePath: AppImages.bomb, isLeft: false),
            TutorialFruitComponent(text: 'Chama', imagePath: AppImages.flame, isLeft: false),
          ],
        )..position = Vector2(0, 50),
      ]);

      game.isDesktop = true;
    } else {
      game.isDesktop = false;
    }

    // Adiciona os componentes de botão e textos de regra
    addAll([
      // Botão principal para iniciar o jogo
      _button = RoundedButton(
        text: 'Iniciar',
        onPressed: () {
          game.startBgmMusic();
          game.router.pushNamed(AppRouter.gamePage);
        },
        bgColor: AppColors.blue,
        borderColor: AppColors.white,
      ),

      // Regras relacionadas às bombas e frutas
      _tutorialRuleLose1Component = SimpleCenterText(
        text: 'Se a bomba explodir, o partida é finalizada,',
        textColor: AppColors.white,
        fontSize: game.isDesktop ? 28 : 20,
      ),
      _tutorialRuleLose2Component = SimpleCenterText(
        text: 'Se faltar três frutas, a partida é finalizada.',
        textColor: AppColors.white,
        fontSize: game.isDesktop ? 28 : 20,
      ),
      _tutorialRuleScore1Component = SimpleCenterText(
        text: 'Acertar uma fruta vale 1 ponto,',
        textColor: AppColors.white,
        fontSize: game.isDesktop ? 28 : 20,
      ),
      _tutorialRuleScore2Component = SimpleCenterText(
        text: 'Uma fruta pode render vários pontos.',
        textColor: AppColors.white,
        fontSize: game.isDesktop ? 28 : 20,
      ),

      // Componente interativo para escolher o modo (fácil, médio, difícil)
      _gameModeComponent = InteractiveButtonComponent(
        size: Vector2(50, 50), // Ajustar tamanho, se necessário
        position: Vector2(150, 200), // Ajustar posição, se necessário
      )..anchor = Anchor.bottomRight,
    ]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // Centraliza o botão na tela
    _button.position = size / 2;

    // Posicionamento dinâmico dos textos de regra
    _tutorialRuleScore1Component.position =
        Vector2(game.size.x / 2, game.size.y - game.size.y / 3.9);
    _tutorialRuleScore2Component.position =
        Vector2(game.size.x / 2, game.size.y - game.size.y / 5.1);
    _tutorialRuleLose1Component.position = Vector2(game.size.x / 2, game.size.y / 5.1);
    _tutorialRuleLose2Component.position = Vector2(game.size.x / 2, game.size.y / 3.9);

    // Posiciona o botão de modo de jogo no canto inferior direito
    _gameModeComponent.position = Vector2(game.size.x - 50, game.size.y - 50);

    // Se for desktop, reposiciona o texto "Bomba" no canto superior direito
    if (game.isDesktop) {
      _bombTextComponent.position = Vector2(game.size.x - 45, 10);
    }
  }
}
