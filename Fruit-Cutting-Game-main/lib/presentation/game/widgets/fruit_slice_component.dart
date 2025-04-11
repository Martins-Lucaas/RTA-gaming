import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:fruit_cutting_game/core/configs/theme/app_colors.dart';
import 'dart:math';

// Defines a component for the fruit slicing effect, using particles to create the visual effect.
class FruitSliceComponent extends ParticleSystemComponent {
  // Constructor that initializes the particle system with the given position
  FruitSliceComponent(Vector2 position)
      : super(
          // Generates a particle effect
          particle: Particle.generate(
            count: 15, // Number of particles to generate (reduced for performance)
            lifespan: 0.5, // Duration each particle stays visible on the screen

            // Defines how each particle is generated
            generator: (i) {
              final random = Random(); // Random instance for generating varied values

              // List of colors used for particles
              final colors = [
                AppColors.darkOrange,
                Colors.red,
                Colors.yellow,
                Colors.green,
                Colors.blue,
              ];

              // Creates an individual particle with acceleration and speed
              return AcceleratedParticle(
                acceleration: Vector2(
                  (random.nextDouble() - 0.5) * 25, // Random acceleration on the x-axis
                  (random.nextDouble() - 0.5) * 25, // Random acceleration on the y-axis
                ),
                speed: Vector2(
                  (random.nextDouble() - 0.5) * 50, // Random initial speed on the x-axis
                  (random.nextDouble() - 0.5) * 50, // Random initial speed on the y-axis
                ),
                position: position, // Initial position of the particle
                child: CircleParticle(
                  radius: 1 + random.nextDouble() * 2, // Random radius between 1 and 3
                  paint: Paint()
                    ..color = colors[random.nextInt(colors.length)], // Random color from the list
                ),
              );
            },
          ),
        );
}
