import 'package:flutter/material.dart';
import 'package:outmed/core/constants/app_colors.dart';

class GlossyCard extends StatelessWidget {
  const GlossyCard({
    required this.child,
    this.padding,
    this.onTap,
    this.radius = 16,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF2FBFA)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .95)),
        boxShadow: AppColors.glossyShadow,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: card,
      ),
    );
  }
}
