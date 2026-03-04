import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Reusable glassmorphic card with frosted-glass effect.
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? margin;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
