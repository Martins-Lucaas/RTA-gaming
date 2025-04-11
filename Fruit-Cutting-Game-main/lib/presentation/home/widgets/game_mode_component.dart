import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:fruit_cutting_game/core/configs/assets/app_images.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';
import 'package:fruit_cutting_game/main_router_game.dart';

// InteractiveButtonComponent represents a button with an image and text that can be interacted with.
class InteractiveButtonComponent extends PositionComponent
    with TapCallbacks, HasGameReference<MainRouterGame> {
  // List of text labels for different game modes.
  final List<String> texts = [
    'easy',
    'medium',
    'hard',
  ];

  // List of image paths corresponding to each game mode.
  final List<String> imagePaths = [
    AppImages.cherry,
    AppImages.banana,
    AppImages.kiwi,
  ];

  late SpriteComponent spriteComponent; // Component for displaying the sprite (image).
  late TextComponent textComponent; // Component for displaying the text.

  // Constructor that allows setting the position and size of the button.
  InteractiveButtonComponent({
    super.position,
    super.size,
  });

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Paint style for the text component.
    final textPaint = TextPaint(
      style: const TextStyle(
        fontSize: 22,
        color: AppColors.white,
        fontFamily: 'Marshmallow',
        letterSpacing: 3.0,
      ),
    );

    // Load the initial image based on the current game mode.
    final initialImage = await Flame.images.load(imagePaths[game.mode]);
    spriteComponent = SpriteComponent(
      sprite: Sprite(initialImage), // Set the sprite with the loaded image.
      size: size, // Set the size of the sprite component.
    );

    // Create the text component with the current mode's text.
    textComponent = TextComponent(
      text: texts[game.mode], // Set the initial text based on the game mode.
      position: Vector2(size.x / 2, size.y + 10), // Position the text below the image.
      anchor: Anchor.topCenter, // Anchor the text at the top center.
      textRenderer: textPaint, // Use the defined text paint style.
    );

    // Add the sprite and text components to the InteractiveButtonComponent.
    add(spriteComponent);
    add(textComponent);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Handle tap down event to trigger the next state.
    _nextState();
  }

  void _nextState() async {
    // Move to the next game mode index in a circular manner.
    game.saveMode((game.mode + 1) % texts.length);

    // Update the displayed text to the new game mode.
    textComponent.text = texts[game.mode];

    // Load and update the image for the new game mode.
    final newImage = await Flame.images.load(imagePaths[game.mode]);
    spriteComponent.sprite = Sprite(newImage); // Update the sprite with the new image.
  }
}
