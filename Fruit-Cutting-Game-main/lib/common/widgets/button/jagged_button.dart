import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';

/// Enum to specify the jagged border position.
enum JaggedBorderPosition {
  top,
  bottom,
  none, // Option for a normal border without jagged effect
}

/// A custom jagged button component for the game.
/// This button has a customizable background color and a jagged border.
class JaggedButton extends PositionComponent with TapCallbacks {
  /// The text displayed on the button.
  final String text;

  /// The background color of the button.
  final Color bgColor;

  /// The color of the button's border.
  final Color borderColor;

  /// The callback function that is triggered when the button is pressed.
  final VoidCallback onPressed;

  /// The position of the jagged border.
  final JaggedBorderPosition borderPosition;

  /// A `TextPainter` object to manage the rendering of the button's text.
  final TextPainter _textDrawable;

  /// Offset for positioning the text in the center of the button.
  late final Offset _textOffset;

  /// Paint object for drawing the border.
  late final Paint _borderPaint;

  /// Paint object for drawing the background.
  late final Paint _bgPaint;

  /// Constructor for the `JaggedButton`.
  JaggedButton({
    required this.text,
    required this.onPressed,
    required this.bgColor,
    required this.borderColor,
    required this.borderPosition,
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
    // Sets the button size based on the text width
    size = Vector2(
      _textDrawable.width + 100, // Adding padding for the button width
      50,
    );

    // Centers the text inside the button
    _textOffset = Offset(
      (size.x - _textDrawable.width) / 2, // Horizontal offset
      (size.y - _textDrawable.height) / 2, // Vertical offset
    );

    // Paint for the background of the button
    _bgPaint = Paint()..color = bgColor;

    // Paint for the border of the button
    _borderPaint = Paint()
      ..style = PaintingStyle.stroke // Border style
      ..strokeWidth = 7.0 // Border thickness
      ..color = borderColor;
  }

  /// Renders the button on the canvas.
  @override
  void render(Canvas canvas) {
    // Draws the background rectangle
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _bgPaint);

    // Draws the jagged border only if it's set
    if (borderPosition == JaggedBorderPosition.none) {
      // Draw normal border without jagged effect
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _borderPaint);
    } else {
      // Draws the jagged border if specified
      drawJaggedBorder(canvas);

      // Draw the normal borders for the other edges
      drawNormalBorders(canvas);
    }

    // Paints the text on the button
    _textDrawable.paint(canvas, _textOffset);
  }

  /// Draws a jagged border around the button.
  void drawJaggedBorder(Canvas canvas) {
    final Path path = Path();

    // Set starting point for the jagged effect based on the position
    double yOffset = borderPosition == JaggedBorderPosition.top ? -3 : size.y + 3;

    for (int i = 0; i <= 10; i++) {
      // Create a jagged effect by moving up and down
      double x = i * (size.x / 10);
      double y = (i % 2 == 0) ? yOffset - 2 : yOffset + 2; // Adjust height based on position
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    if (borderPosition == JaggedBorderPosition.top ||
        borderPosition == JaggedBorderPosition.bottom) {
      path.lineTo(size.x, 0); // Complete the top right
      path.lineTo(0, 0); // Complete the top left
    } else {
      path.lineTo(size.x, size.y); // Complete the bottom right
      path.lineTo(0, size.y); // Complete the bottom left
    }

    path.close(); // Close the path

    canvas.drawPath(path, _borderPaint); // Draw the jagged border
  }

  /// Draws normal borders for the other edges of the button.
  void drawNormalBorders(Canvas canvas) {
    // Draw normal border for the left edge
    canvas.drawLine(const Offset(0, 0), Offset(0, size.y), _borderPaint);
    // Draw normal border for the right edge
    canvas.drawLine(Offset(size.x, 0), Offset(size.x, size.y), _borderPaint);
    // Draw normal border for the bottom edge (only if not bottom jagged)
    if (borderPosition != JaggedBorderPosition.bottom) {
      canvas.drawLine(Offset(0, size.y), Offset(size.x, size.y), _borderPaint);
    }
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
