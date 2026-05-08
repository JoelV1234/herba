import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Subtle decorative blobs evoking foliage / dappled light.
class LeafBackground extends StatelessWidget {
  final Widget child;
  const LeafBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _BlobsPainter()),
        ),
        child,
      ],
    );
  }
}

class _BlobsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.shader = RadialGradient(
      colors: [
        AppColors.sage.withValues(alpha: 0.55),
        AppColors.sage.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.85, size.height * 0.12),
      radius: size.width * 0.55,
    ));
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.12),
      size.width * 0.55,
      paint,
    );

    paint.shader = RadialGradient(
      colors: [
        AppColors.mint.withValues(alpha: 0.7),
        AppColors.mint.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * -0.1, size.height * 0.6),
      radius: size.width * 0.7,
    ));
    canvas.drawCircle(
      Offset(size.width * -0.1, size.height * 0.6),
      size.width * 0.7,
      paint,
    );

    paint.shader = null;
    paint.color = AppColors.leaf.withValues(alpha: 0.06);
    final rng = Random(42);
    for (var i = 0; i < 14; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      final r = 4.0 + rng.nextDouble() * 10;
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
