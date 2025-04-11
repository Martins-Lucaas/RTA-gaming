import 'dart:math';
import 'package:flame/input.dart';

class AppUtils {
  // This function calculates the angle (in degrees) between the center of an object and the touch point.
  // `center`: the position of the object's center, which serves as a reference point
  // `initAngle`: the initial angle offset of the object
  // `touch`: the coordinates of where the user touched

  static int getAngleOfTouchPont({
    required Vector2 center,
    required double initAngle,
    required Vector2 touch,
  }) {
    // 1. Calculate the vector from the object's center to the touch point.
    // First, we calculate the vector between the center of the object and the touch point by subtracting `center` from `touch`.
    // The result is a new vector that gives the position of the touch relative to the object’s center.
    final touchPoint = touch - center;

    // 2. Calculate the angle of this vector in radians
    // The `atan2(y, x)` function returns the angle in radians between the x-axis and the vector `touchPoint`.
    // This angle represents the direction of the touch relative to the center of the object.
    double angle = atan2(touchPoint.y, touchPoint.x);

    // 3. Adjust the angle by subtracting the `initAngle`
    // This step adjusts the angle by the initial offset of the object, so it aligns with the object's current orientation.
    angle -= initAngle;

    // 4. Normalize the angle to a range of 0 to 2π
    // This ensures that the angle always stays within the range of 0 to 2π (equivalent to 0 to 360 degrees) by using the modulus operator.
    angle %= 2 * pi;

    // 5. Convert radians to degrees and return the result
    // The `radiansToDegrees` function converts the angle from radians to degrees, and the result is rounded to an integer before returning.
    return radiansToDegrees(angle).toInt();
  }

  // Helper function to convert radians to degrees
  static double radiansToDegrees(double angle) => angle * 180 / pi;
}
