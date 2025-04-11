import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';

/// A simple button component that can be tapped.
/// The button is built using `PositionComponent` from the Flame framework
/// and responds to tap events (e.g., onTapDown, onTapUp).
/// It includes a customizable border and icon style.
abstract class SimpleButton extends PositionComponent with TapCallbacks {
  // Paint for the button's border with a light gray color and stroke style.
  final Paint _borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = AppColors.lightGray
    ..strokeWidth = 3.0; // Đặt độ dày của viền ở đây

  // Paint for the button's icon, using a stroke style and gray color.
  final Paint _iconPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = AppColors.strokeGray
    ..strokeWidth = 7;

  // The path used to draw the button's icon.
  final Path _iconPath;

  // A callback function that is triggered when the button is tapped.
  VoidCallback? action;

  /// Constructor for the `SimpleButton` class.
  ///
  /// - `_iconPath`: The path that defines the shape of the icon to be drawn inside the button.
  /// - `position`: The position of the button on the screen.
  /// - `action`: The function to be called when the button is tapped.
  ///
  /// The button is sized to 40x40 pixels with a border and icon.
  SimpleButton(
    this._iconPath, {
    super.position,
    this.action,
  }) : super(
          size: Vector2.all(40), // Sets the button's size to 40x40
        );

  /// Renders the button on the canvas.
  ///
  /// This method draws a rounded rectangle as the button's border
  /// and the provided icon path inside the button.
  @override
  void render(Canvas canvas) {
    // Draw the button's border with rounded corners (radius of 8).
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        size.toRect(),
        const Radius.circular(8),
      ),
      _borderPaint,
    );

    // Draw the button's icon using the provided path and icon paint.
    canvas.drawPath(_iconPath, _iconPaint);
  }

  /// Changes the icon color to white when the button is pressed down.
  @override
  void onTapDown(TapDownEvent event) {
    _iconPaint.color = AppColors.white; // Change icon color to white on tap
  }

  /// Resets the icon color to gray when the button is released.
  @override
  void onTapUp(TapUpEvent event) {
    _iconPaint.color = AppColors.strokeGray; // Change back to gray on tap release
    action?.call();
  }

  /// Resets the icon color to gray when the tap is canceled.
  @override
  void onTapCancel(TapCancelEvent event) {
    _iconPaint.color = AppColors.strokeGray; // Revert to gray if tap is canceled
  }
}
