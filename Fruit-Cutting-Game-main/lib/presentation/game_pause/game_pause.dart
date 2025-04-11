import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart' hide Game; // Hides the Game class to avoid naming conflicts.
import 'package:flame/rendering.dart';
import 'package:flame/text.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';
import 'package:fruit_cutting_game/main_router_game.dart';

/// This class represents the route for the pause screen in the game.
class PauseRoute extends Route {
  /// Constructor for PauseRoute, sets it to show GamePausePage.
  PauseRoute() : super(GamePausePage.new, transparent: true);

  /// When this route is pushed (opened), stop the game time and apply a gray effect to the background.
  @override
  void onPush(Route? previousRoute) {
    previousRoute!
      ..stopTime() // Stops the game's time.
      ..addRenderEffect(
        // Adds a visual effect to the background.
        PaintDecorator.grayscale(opacity: 0.5) // Makes the background gray.
          ..addBlur(3.0), // Adds a blur effect to the background.
      );
  }

  /// When this route is popped (closed), resume game time and remove effects.
  @override
  void onPop(Route nextRoute) {
    nextRoute
      ..resumeTime() // Resumes the game's time.
      ..removeRenderEffect(); // Removes the visual effects from the background.
  }
}

/// This class represents the pause page displayed when the game is paused.
class GamePausePage extends Component with TapCallbacks, HasGameReference<MainRouterGame> {
  late TextComponent _textComponent; // Text component to show the "PAUSED" message.

  /// Load the components for the pause page.
  @override
  Future<void> onLoad() async {
    final game = findGame()!; // Find the current game instance.

    final textTitlePaint = TextPaint(
      style: const TextStyle(
        fontSize: 60,
        color: AppColors.white,
        fontFamily: 'Insan',
        letterSpacing: 2.0,
      ),
    );
    // Add the text component to display "PAUSED".
    addAll([
      _textComponent = TextComponent(
        text: 'PAUSED',
        position: game.canvasSize / 2,
        anchor: Anchor.center,
        children: [
          // Add a scaling effect to the text to make it pulsate.
          ScaleEffect.to(
            Vector2.all(1.1), // Scale the text up to 110%.
            EffectController(
              duration: 0.3, // Duration of the scaling effect.
              alternate: true, // Make the effect go back and forth.
              infinite: true, // Repeat the effect forever.
            ),
          ),
        ],
        textRenderer: textTitlePaint,
      ),
    ]);
  }

  /// Called when the game is resized; updates text position to stay centered.
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _textComponent.position = size / 2;
  }

  /// Always returns true, indicating that this component can contain tap events.
  @override
  bool containsLocalPoint(Vector2 point) {
    return true; // Accept all tap events.
  }

  /// Handle tap up events; navigate back to the previous screen when tapped.
  @override
  void onTapUp(TapUpEvent event) {
    game.router.pop(); // Go back to the previous route (unpause the game).
  }
}
