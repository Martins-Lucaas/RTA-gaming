import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/image_composition.dart' as composition;
import 'package:flutter/foundation.dart';
import 'package:fruit_cutting_game/common/helpers/app_utils.dart';
import 'package:fruit_cutting_game/core/configs/constants/app_configs.dart';
import 'package:fruit_cutting_game/data/models/fruit_model.dart';
import 'package:fruit_cutting_game/main_router_game.dart';
import 'package:fruit_cutting_game/presentation/game/game.dart';

/// A component representing a fruit in the game.
/// This class manages the fruit's behavior, movement, and interactions.
class FruitComponent extends SpriteComponent with HasGameReference<MainRouterGame> {
  Vector2 velocity; // Speed and direction of the fruit.
  final Vector2 pageSize; // Size of the game page.
  final double acceleration; // Acceleration applied to the fruit's velocity.
  final FruitModel fruit; // Data model for the fruit.
  final composition.Image image; // Image representing the fruit.
  late Vector2 _initPosition; // Initial position of the fruit.
  bool canDragOnShape = false; // Flag to determine if the fruit can be dragged.
  GamePage parentComponent; // Reference to the game page.
  bool divided; // Flag indicating if the fruit has been cut.

  /// Constructor for the `FruitComponent` class.
  ///
  /// - `parentComponent`: The parent game page that contains this fruit.
  /// - `p`: The position of the fruit on the screen.
  /// - `size`: Optional size of the fruit.
  /// - `velocity`: Required initial velocity of the fruit.
  /// - `acceleration`: Required acceleration for the fruit.
  /// - `pageSize`: Required size of the game page.
  /// - `image`: Required image for the fruit.
  /// - `fruit`: Required fruit model.
  /// - `angle`: Optional initial angle of rotation.
  /// - `anchor`: Optional anchor point for positioning.
  /// - `divided`: Indicates if the fruit is already cut.
  FruitComponent(
    this.parentComponent,
    Vector2 p, {
    super.size, // Optional size.
    required this.velocity, // Required velocity.
    required this.acceleration, // Required acceleration.
    required this.pageSize, // Required page size.
    required this.image, // Required image.
    required this.fruit, // Required fruit model.
    super.angle, // Optional rotation angle.
    Anchor? anchor, // Optional anchor point.
    this.divided = false, // Default divided state.
  }) : super(
          sprite: Sprite(image), // Initialize sprite with the fruit's image.
          position: p, // Set size of the fruit.
          anchor: anchor ?? Anchor.center, // Set angle of rotation.
        ) {
    _initPosition = p; // Store initial position.
    canDragOnShape = false; // Initially, dragging is disabled.
  }

  @override
  void update(double dt) {
    // Update the fruit's state.
    super.update(dt); // Call parent class's update method.
    if (_initPosition.distanceTo(position) > 60) {
      canDragOnShape = true; // Enable dragging if moved far enough.
    }
    angle += .5 * dt; // Rotate the fruit based on time.
    angle %= 2 * pi; // Keep angle within 0 to 2π.

    // Update position based on velocity and gravity.
    position += Vector2(velocity.x, -(velocity.y * dt - .5 * AppConfig.gravity * dt * dt));

    // Update vertical velocity with acceleration and gravity.
    velocity.y += (AppConfig.acceleration + AppConfig.gravity) * dt;

    // Remove fruit if it goes off-screen.
    if ((position.y - AppConfig.objSize) > pageSize.y) {
      removeFromParent(); // Remove the fruit from the game.

      // Increment mistake count if the fruit is not divided and is not a bomb.
      if (!divided && !fruit.isBomb) {
        parentComponent.addMistake();
      }
    }
  }

  /// Handles touch events on the fruit, determining if and how the fruit should be cut,
  /// and whether the game should end if a bomb is touched.
  ///
  /// - `vector2`: The point where the fruit was touched.
  void touchAtPoint(Vector2 vector2) async {
    // Prevent any action if the fruit has already been divided and dragging is disabled.
    if (divided && !canDragOnShape) {
      return; // Exit if already divided.
    }

    // Check if the fruit is a bomb.
    if (fruit.isBomb) {
      parentComponent.gameOver(); // End the game if a bomb is touched.
      return;
    }

    // NOTE: Removed fruit splitting feature because of unfixed 'toImageSync' bug on Flutter SDK
    // check here: https://github.com/flutter/flutter/issues/144451
    //
    if (game.isDesktop) {
      // 1. Calculate the angle between the touch point and the fruit’s center.
      // This angle helps determine the slicing direction.
      // Formula: `atan2(dy, dx)` where `dy = touchPoint.y - center.y` and `dx = touchPoint.x - center.x`.
      // `atan2` returns the angle between the positive x-axis and the vector from (0, 0) to (dx, dy) in radians.
      // The resulting angle helps identify whether the touch is in a vertical or horizontal slicing direction.
      final a = AppUtils.getAngleOfTouchPont(center: position, initAngle: angle, touch: vector2);

      try {
        // 2. Check if the calculated angle falls along a vertical or horizontal slice.
        // This check uses angle ranges to decide the slicing direction:
        // Vertical slices: angle between 0-45°, 135-225°, 315-360°
        // Horizontal slices: angle between 45-135° and 225-315°.
        if (a < 45 || (a > 135 && a < 225) || a > 315) {
          // Vertical slice: Create two halves of the fruit.
          final dividedImage1 = await createDividedImage(
              image, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height / 2));
          final dividedImage2 = await createDividedImage(
              image, Rect.fromLTWH(0, image.height / 2, image.width.toDouble(), image.height / 2));

          // 3. Position adjustments using cosine and sine for direction:
          // The formula used to adjust the position of each half of the fruit is based on vector rotation.
          // For the upper half, the position is adjusted by subtracting a vector: `Vector2(size.x / 2 * cos(angle), size.x / 2 * sin(angle))`
          // For the lower half, the position is adjusted similarly with the opposite direction for the slice.
          parentComponent.addAll([
            // Adjust position for the upper half of the fruit after slicing
            // The formula used here is based on vector rotation:

            // 3.1. `size.x / 2`: This is half the width of the fruit, determining the distance
            //    from the center to the edge of the fruit for the upper half after slicing.

            // 3.2. `cos(angle)`: This gives the horizontal (x-axis) component of the vector
            //    that defines the direction of movement for the upper half, based on the angle of the slice.
            //    It determines how far to move the upper half horizontally.

            // 3.3. `sin(angle)`: This gives the vertical (y-axis) component of the vector
            //    that defines the direction of movement for the upper half, based on the angle of the slice.
            //    It determines how far to move the upper half vertically.

            // 3.4. `center - Vector2(...)`: By subtracting the calculated vector from the center,
            //    we adjust the position of the upper half of the fruit, moving it in the correct direction
            //    after the slice, according to the calculated angle.
            FruitComponent(
              parentComponent,
              center -
                  Vector2(size.x / 2 * cos(angle),
                      size.x / 2 * sin(angle)), // Adjust position for upper half.
              fruit: fruit,
              image: dividedImage2,
              acceleration: acceleration,
              velocity: Vector2(velocity.x - 2,
                  velocity.y), // Apply slightly different velocities for split effect.
              pageSize: pageSize,
              divided: true, // Mark as divided.
              size: Vector2(size.x, size.y / 2), // Adjust size for top half.
              angle: angle,
              anchor: Anchor.topLeft,
            ),

            // Adjust position for the lower half of the fruit after slicing
            // Similar to the upper half, but with adjustments for the lower side:

            // 3.5. `size.x / 4`: This is a quarter of the width of the fruit, determining the distance
            //      from the center to the edge of the fruit for the lower half after slicing.

            // 3.6. `cos(angle + 3 * pi / 2)`: This gives the horizontal (x-axis) component for the lower half's direction.
            //      By adding `3 * pi / 2` to the angle, we rotate the vector to move the lower half in the opposite direction.

            // 3.7. `sin(angle + 3 * pi / 2)`: This gives the vertical (y-axis) component for the lower half's direction.
            //      Adding `3 * pi / 2` rotates the vertical direction to move the lower half.

            // 3.8. `center + Vector2(...)`: By adding the calculated vector to the center,
            //      we adjust the position of the lower half of the fruit, moving it in the correct direction
            //      after the slice, according to the modified angle.
            FruitComponent(
              parentComponent,
              center +
                  Vector2(size.x / 4 * cos(angle + 3 * pi / 2),
                      size.x / 4 * sin(angle + 3 * pi / 2)), // Adjust position for lower half.
              size: Vector2(size.x, size.y / 2), // Adjust size for bottom half.
              angle: angle,
              anchor: Anchor.center,
              fruit: fruit,
              image: dividedImage1,
              acceleration: acceleration,
              velocity: Vector2(velocity.x + 2, velocity.y), // Different velocity for other half.
              pageSize: pageSize,
              divided: true, // Mark as divided.
            ),
          ]);
        } else {
          // Horizontal slice: Create two halves of the fruit.
          final dividedImage1 = await createDividedImage(
              image, Rect.fromLTWH(0, 0, image.width / 2, image.height.toDouble()));
          final dividedImage2 = await createDividedImage(
              image, Rect.fromLTWH(image.width / 2, 0, image.width / 2, image.height.toDouble()));

          // 4. Position adjustments for horizontal slice:
          // The formulas for adjusting the position are similar to the vertical slice, but with a different factor for horizontal separation.
          parentComponent.addAll([
            // Adjust position for the left half of the fruit after slicing
            // The formula used here is based on vector rotation:
            // 4.1. `size.x / 4`: This is a quarter of the width of the fruit, determining the distance
            //      from the center to the edge of the fruit for the left half after slicing.

            // 4.2. `cos(angle)`: This gives the horizontal (x-axis) component of the vector
            //      that defines the direction of movement for the left half, based on the angle of the slice.
            //      It determines how far to move the left half horizontally.

            // 4.3. `sin(angle)`: This gives the vertical (y-axis) component of the vector
            //      that defines the direction of movement for the left half, based on the angle of the slice.
            //      It determines how far to move the left half vertically.

            // 4.4. `center - Vector2(...)`: By subtracting the calculated vector from the center,
            //      we adjust the position of the left half of the fruit, moving it in the correct direction
            //      after the slice, according to the calculated angle.
            FruitComponent(
              parentComponent,
              center -
                  Vector2(size.x / 4 * cos(angle),
                      size.x / 4 * sin(angle)), // Adjust position for left half.
              size: Vector2(size.x / 2, size.y), // Adjust size for left half.
              angle: angle,
              anchor: Anchor.center,
              fruit: fruit,
              image: dividedImage1,
              acceleration: acceleration,
              velocity:
                  Vector2(velocity.x - 2, velocity.y), // Apply velocity change for split effect.
              pageSize: pageSize,
              divided: true, // Mark as divided.
            ),

            // Adjust position for the right half of the fruit after slicing
            // Similar to the left half, but with adjustments for the right side:

            // 4.5. `size.x / 2`: This is half the width of the fruit, determining the distance
            //      from the center to the edge of the fruit for the right half after slicing.

            // 4.6. `cos(angle + 3 * pi / 2)`: This gives the horizontal (x-axis) component for the right half's direction.
            //      By adding `3 * pi / 2` to the angle, we effectively rotate the movement in the opposite direction.

            // 4.7. `sin(angle + 3 * pi / 2)`: This gives the vertical (y-axis) component for the right half's direction.
            //      Similar to `cos`, adding `3 * pi / 2` rotates the vertical direction to move the right half.

            // 4.8. `center + Vector2(...)`: By adding the calculated vector to the center,
            //      we adjust the position of the right half of the fruit, moving it in the correct direction
            //      after the slice, based on the modified angle.
            FruitComponent(
              parentComponent,
              center +
                  Vector2(size.x / 2 * cos(angle + 3 * pi / 2),
                      size.x / 2 * sin(angle + 3 * pi / 2)), // Adjust position for right half.
              size: Vector2(size.x / 2, size.y), // Adjust size for right half.
              angle: angle,
              anchor: Anchor.topLeft,
              fruit: fruit,
              image: dividedImage2,
              acceleration: acceleration,
              velocity:
                  Vector2(velocity.x + 2, velocity.y), // Apply different velocity for other half.
              pageSize: pageSize,
              divided: true, // Mark as divided.
            ),
          ]);
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('Error adding components: $e\n$stackTrace');
        }
      }
    }

    parentComponent.addScore(); // Update the score when fruit is successfully cut.
    removeFromParent(); // Remove the original, whole fruit from the game.
  }

  Future<Image> createDividedImage(Image originalImage, Rect sourceRect) async {
    // Create a PictureRecorder to record drawing operations on the Canvas
    final recorder = PictureRecorder();

    // Create a Canvas to draw the image, linked to the recorder
    final canvas = Canvas(recorder);

    // Create a Paint (no special settings) to use for drawing
    final paint = Paint();

    // Draw the specified portion of the original image (sourceRect) onto the Canvas
    canvas.drawImageRect(
      originalImage, // The original image
      sourceRect, // The region to cut from the original image
      Rect.fromLTWH(0, 0, sourceRect.width, sourceRect.height), // Destination rect on the Canvas
      paint, // Default paint
    );

    // End recording and get the Picture object
    final picture = recorder.endRecording();

    // Convert the Picture to an Image with the specified width and height
    return await picture.toImage(sourceRect.width.toInt(), sourceRect.height.toInt());
  }
}
