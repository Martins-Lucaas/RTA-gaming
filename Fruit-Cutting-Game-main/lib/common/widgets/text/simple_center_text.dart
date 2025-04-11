import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

/// A custom text component for the game, with flexible styling and tap interaction support.
class SimpleCenterText extends PositionComponent with TapCallbacks {
  /// The text displayed by this component.
  final String text;

  /// The color of the text.
  final Color textColor;

  /// The font size of the text.
  final double fontSize;

  /// A `TextPainter` object to manage the rendering of the text.
  late final TextPainter _textPainter;

  /// Offset for positioning the text in the center of the component.
  late final Offset _textOffset;

  /// Constructor for the `CustomTextComponent`.
  ///
  /// - `text`: The text to be displayed.
  /// - `textColor`: The color of the text.
  /// - `fontSize`: The font size of the text.
  /// - `onTap`: An optional callback triggered when the text is tapped.
  SimpleCenterText({
    required this.text,
    required this.textColor,
    required this.fontSize,
    super.anchor = Anchor.center,
  }) {
    _textPainter = TextPaint(
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontWeight: FontWeight.w200,
        fontFamily: 'Insan',
        letterSpacing: 1.5,
      ),
    ).toTextPainter(text);

    // Set size to fit the text
    size = Vector2(200, 60);

    // Calculate the offset to center the text inside the component
    _textOffset = Offset((size.x - _textPainter.width) / 2, (size.y - _textPainter.height) / 2);
  }

  /// Renders the text on the canvas.
  @override
  void render(Canvas canvas) {
    _textPainter.paint(canvas, _textOffset);
  }
}
