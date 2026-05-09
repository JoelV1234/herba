import 'dart:math';

import 'package:flutter/material.dart';

import '../../../models/controller_status.dart';
import '../../../theme/app_colors.dart';

class TemperatureDial extends StatelessWidget {
  final double currentC;
  final double targetC;
  final HeaterState heaterState;
  final ValueChanged<double>? onTargetChanged;

  const TemperatureDial({
    super.key,
    required this.currentC,
    required this.targetC,
    required this.heaterState,
    this.onTargetChanged,
  });

  static const double minC = 5;
  static const double maxC = 30;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isHeating = heaterState == HeaterState.heating;
    final dialColor =
        isHeating ? AppColors.ember : scheme.primary;
    return Column(
      children: [
        SizedBox(
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(260, 260),
                painter: _DialPainter(
                  current: currentC,
                  target: targetC,
                  isHeating: isHeating,
                  trackColor: context.mintTint,
                  tickColor: scheme.outlineVariant,
                  targetColor: scheme.primary,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Inside',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      text: currentC.toStringAsFixed(1),
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: dialColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 76,
                        height: 1,
                      ),
                      children: [
                        TextSpan(
                          text: '°C',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: dialColor.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.mint,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'Target ${targetC.toStringAsFixed(1)}°C',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.forest,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: targetC.clamp(minC, maxC),
            min: minC,
            max: maxC,
            divisions: ((maxC - minC) * 2).round(),
            label: '${targetC.toStringAsFixed(1)}°C',
            onChanged: onTargetChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${minC.round()}°C',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text('${maxC.round()}°C',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DialPainter extends CustomPainter {
  final double current;
  final double target;
  final bool isHeating;
  final Color trackColor;
  final Color tickColor;
  final Color targetColor;

  _DialPainter({
    required this.current,
    required this.target,
    required this.isHeating,
    required this.trackColor,
    required this.tickColor,
    required this.targetColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 16;

    // Outer track.
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = trackColor;

    const startAngle = pi * 0.75;
    const sweep = pi * 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      trackPaint,
    );

    // Progress arc up to current temp.
    final pct = ((current - TemperatureDial.minC) /
            (TemperatureDial.maxC - TemperatureDial.minC))
        .clamp(0.0, 1.0);
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweep,
        colors: isHeating
            ? const [AppColors.sun, AppColors.ember]
            : const [AppColors.leaf, AppColors.forest],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep * pct,
      false,
      progressPaint,
    );

    // Target tick.
    final targetPct = ((target - TemperatureDial.minC) /
            (TemperatureDial.maxC - TemperatureDial.minC))
        .clamp(0.0, 1.0);
    final tickAngle = startAngle + sweep * targetPct;
    final inner = Offset(
      center.dx + cos(tickAngle) * (radius - 22),
      center.dy + sin(tickAngle) * (radius - 22),
    );
    final outer = Offset(
      center.dx + cos(tickAngle) * (radius + 4),
      center.dy + sin(tickAngle) * (radius + 4),
    );
    final tickPaint = Paint()
      ..color = targetColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(inner, outer, tickPaint);

    // Tick markers around the arc every 5°C.
    for (var t = TemperatureDial.minC; t <= TemperatureDial.maxC; t += 5) {
      final p = (t - TemperatureDial.minC) /
          (TemperatureDial.maxC - TemperatureDial.minC);
      final angle = startAngle + sweep * p;
      final a = Offset(
        center.dx + cos(angle) * (radius + 10),
        center.dy + sin(angle) * (radius + 10),
      );
      final b = Offset(
        center.dx + cos(angle) * (radius + 18),
        center.dy + sin(angle) * (radius + 18),
      );
      final markerPaint = Paint()
        ..color = tickColor
        ..strokeWidth = 2;
      canvas.drawLine(a, b, markerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.current != current ||
      old.target != target ||
      old.isHeating != isHeating ||
      old.trackColor != trackColor ||
      old.tickColor != tickColor ||
      old.targetColor != targetColor;
}
