import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:fruit_cutting_game/common/widgets/button/simple_button.dart';
import 'package:fruit_cutting_game/main_router_game.dart';

/// A custom back button component that inherits from `SimpleButton`.
/// This button is designed to go back (pop) in the game's navigation stack
/// when pressed, or trigger a custom action if provided.
class BackButtonCustom extends SimpleButton with HasGameReference<MainRouterGame> {
  /// Constructor for the `BackButtonCustom` class.
  ///
  /// - `onPressed`: A callback function that will be called when the button is pressed.
  ///   If not provided, the default action will pop the current screen in the game.
  BackButtonCustom({VoidCallback? onPressed})
      : super(
          // Creates a custom path to draw the back button icon (an arrow).
          Path()
            ..moveTo(22, 8) // Starting point of the top part of the arrow
            ..lineTo(10, 20) // Draws the left diagonal line of the arrow
            ..lineTo(22, 32)
            ..moveTo(12, 20) // Moves to the starting point of the bottom part
            ..lineTo(34, 20), // Draws the horizontal line of the arrow
          position: Vector2.all(10), // Sets the button's position to (10, 10)
        ) {
    // Sets the action to either the provided onPressed callback or
    // the default action, which pops the current route in the game's router.
    super.action = onPressed ?? () => game.router.pop();
  }
}
