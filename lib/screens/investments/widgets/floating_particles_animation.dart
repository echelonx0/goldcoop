// lib/screens/investments/widgets/floating_particles_animation.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Floating gradient particles background animation
/// Used for premium feel on investment landing screen
class FloatingParticlesAnimation extends StatefulWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final int particleCount;

  const FloatingParticlesAnimation({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    this.particleCount = 20,
  });

  @override
  State<FloatingParticlesAnimation> createState() =>
      _FloatingParticlesAnimationState();
}

class _FloatingParticlesAnimationState
    extends State<FloatingParticlesAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _particles = List.generate(
      widget.particleCount,
      (index) => Particle(
        primaryColor: widget.primaryColor,
        secondaryColor: widget.secondaryColor,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(
            particles: _particles,
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  final double x;
  final double y;
  final double size;
  final double speedX;
  final double speedY;
  final Color color;
  final double opacity;

  Particle({
    required Color primaryColor,
    required Color secondaryColor,
  })  : x = math.Random().nextDouble(),
        y = math.Random().nextDouble(),
        size = 20 + math.Random().nextDouble() * 60,
        speedX = (math.Random().nextDouble() - 0.5) * 0.02,
        speedY = (math.Random().nextDouble() - 0.5) * 0.02,
        opacity = 0.1 + math.Random().nextDouble() * 0.15,
        color = math.Random().nextBool() ? primaryColor : secondaryColor;
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlesPainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      // Calculate position with wrapping
      var x = ((particle.x + particle.speedX * animationValue) % 1.0) * size.width;
      var y = ((particle.y + particle.speedY * animationValue) % 1.0) * size.height;

      // Create gradient
      final gradient = RadialGradient(
        colors: [
          particle.color.withAlpha((particle.opacity * 255).toInt()),
          particle.color.withAlpha(0),
        ],
        stops: const [0.0, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(
            center: Offset(x, y),
            radius: particle.size,
          ),
        );

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => true;
}
