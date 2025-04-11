import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';

/// A custom rounded button component for the game.
/// This button is built using Flame's `PositionComponent` and responds to tap events.
///
/// The button displays a text and can trigger an action when pressed.
///
/// The button supports a custom background color, border color, and scales
/// up slightly when pressed to provide a feedback effect.
class RoundedButton extends PositionComponent with TapCallbacks {
  /// The text displayed on the button.
  final String text;

  /// The background color of the button.
  final Color bgColor;

  /// The color of the button's border.
  final Color borderColor;

  /// The callback function that is triggered when the button is pressed.
  final VoidCallback onPressed;

  /// A `TextPainter` object to manage the rendering of the button's text.
  final TextPainter _textDrawable;

  /// Offset for positioning the text in the center of the button.
  late final Offset _textOffset;

  /// Rounded rectangle representing the button's shape.
  late final RRect _rRect;

  /// Paint object for drawing the border.
  late final Paint _borderPaint;

  /// Paint object for drawing the background.
  late final Paint _bgPaint;

  final double sizeX;

  /// Constructor for the `RoundedButton`.
  ///
  /// - `text`: The text to be displayed on the button.
  /// - `onPressed`: The function to be called when the button is pressed.
  /// - `bgColor`: The background color of the button.
  /// - `borderColor`: The border color of the button.
  RoundedButton({
    required this.text,
    required this.onPressed,
    required this.bgColor,
    required this.borderColor,
    this.sizeX = 190,
    super.anchor = Anchor.center,
  }) : _textDrawable = TextPaint(
          style: const TextStyle(
            fontSize: 23,
            color: AppColors.white,
            fontWeight: FontWeight.w800,
            fontFamily: 'Insan',
            letterSpacing: 2.0,
          ),
        ).toTextPainter(text) {
    // Sets the button size
    size = Vector2(sizeX, 50);

    // Centers the text inside the button
    _textOffset = Offset(
      (size.x - _textDrawable.width) / 2, // Horizontal offset
      (size.y - _textDrawable.height) / 2, // Vertical offset
    );

    // Creates a rounded rectangle (RRect) with circular corners
    _rRect = RRect.fromLTRBR(0, 0, size.x, size.y, Radius.circular(size.y / 2));

    // Paint for the background of the button
    _bgPaint = Paint()..color = bgColor;

    // Paint for the border of the button
    _borderPaint = Paint()
      ..style = PaintingStyle.stroke // Border style
      ..strokeWidth = 3 // Border thickness
      ..color = borderColor;
  }

  /// Renders the button on the canvas.
  @override
  void render(Canvas canvas) {
    // Draws the background rounded rectangle
    canvas.drawRRect(_rRect, _bgPaint);

    // Draws the border of the button
    canvas.drawRRect(_rRect, _borderPaint);

    // Paints the text on the button
    _textDrawable.paint(canvas, _textOffset);
  }

  /// Scales up the button when it is tapped down (pressed).
  @override
  void onTapDown(TapDownEvent event) {
    scale = Vector2.all(1.05); // Increases size slightly to indicate a tap
  }

  /// Resets the button's size when the tap is released and triggers the `onPressed` callback.
  @override
  void onTapUp(TapUpEvent event) {
    scale = Vector2.all(1.0); // Resets the button size
    onPressed.call(); // Calls the provided onPressed function
  }

  /// Resets the button's size when the tap is canceled (e.g., when the user moves their finger away).
  @override
  void onTapCancel(TapCancelEvent event) {
    scale = Vector2.all(1.0); // Resets the button size
  }
}
