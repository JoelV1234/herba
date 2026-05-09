import 'package:flutter/material.dart';

class EcoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const EcoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.color,
    this.gradient,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = borderRadius ?? BorderRadius.circular(24);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            color: gradient == null ? (color ?? scheme.surface) : null,
            gradient: gradient,
            borderRadius: radius,
            border: gradient == null
                ? Border.all(color: scheme.outlineVariant)
                : null,
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
