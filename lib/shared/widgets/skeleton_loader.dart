import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer-based skeleton loader.
class SkeletonLoader extends StatelessWidget {
  /// Creates a skeleton loader.
  const SkeletonLoader({
    super.key,
    this.height = 16,
    this.width,
    this.borderRadius = 8,
  });

  /// Height.
  final double height;

  /// Width (defaults to full width).
  final double? width;

  /// Border radius.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlight,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

