import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_colors.dart';

/// Hero-style visual panel for activation screens.
class ActivationVisualPanel extends StatelessWidget {
  /// Creates an activation visual panel.
  const ActivationVisualPanel({
    super.key,
    required this.stepLabel,
    required this.title,
    required this.subtitle,
    this.animationAsset,
    this.fallbackIcon = Icons.verified_user_outlined,
    this.illustrationAsset,
    this.supportingAnimationAsset,
    this.illustrationFallbackIcon = Icons.image_outlined,
    this.supportingFallbackIcon = Icons.auto_awesome_outlined,
    this.animationHeight = 170,
    this.mainSlotLabel = 'Primary illustration / animation',
    this.additionalMediaTitle = 'Additional media slots',
    this.illustrationSlotLabel = 'Illustration slot',
    this.supportingSlotLabel = 'Extra animation slot',
  });

  /// Step label such as "Step 1 of 3".
  final String stepLabel;

  /// Main heading.
  final String title;

  /// Supporting text.
  final String subtitle;

  /// Optional Lottie animation asset path.
  final String? animationAsset;

  /// Fallback icon when animation cannot load.
  final IconData fallbackIcon;

  /// Optional illustration asset path for the first extra media slot.
  final String? illustrationAsset;

  /// Optional animation asset path for the second extra media slot.
  final String? supportingAnimationAsset;

  /// Fallback icon for the illustration slot.
  final IconData illustrationFallbackIcon;

  /// Fallback icon for the extra animation slot.
  final IconData supportingFallbackIcon;

  /// Height allocated to the animation slot.
  final double animationHeight;

  /// Label shown under the main media slot.
  final String mainSlotLabel;

  /// Heading above the two extra media slots.
  final String additionalMediaTitle;

  /// Label for the illustration slot.
  final String illustrationSlotLabel;

  /// Label for the extra animation slot.
  final String supportingSlotLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, Color(0xFF042A67)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1E00193D),
            blurRadius: 20,
            offset: Offset(0, 12),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -34,
            right: -26,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -42,
            left: -26,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  stepLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.86),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: animationHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.24),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _buildAnimationSlot(
                    assetPath: animationAsset,
                    fallback: fallbackIcon,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mainSlotLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.86),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                additionalMediaTitle,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _MediaSlot(
                      assetPath: illustrationAsset,
                      label: illustrationSlotLabel,
                      fallbackIcon: illustrationFallbackIcon,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MediaSlot(
                      assetPath: supportingAnimationAsset,
                      label: supportingSlotLabel,
                      fallbackIcon: supportingFallbackIcon,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationSlot({
    required String? assetPath,
    required IconData fallback,
  }) {
    if (assetPath == null || assetPath.trim().isEmpty) {
      return _FallbackVisual(icon: fallback);
    }

    return Lottie.asset(
      assetPath,
      fit: BoxFit.contain,
      repeat: true,
      frameRate: FrameRate.max,
      errorBuilder: (context, error, stackTrace) =>
          _FallbackVisual(icon: fallback),
    );
  }
}

class _MediaSlot extends StatelessWidget {
  const _MediaSlot({
    required this.assetPath,
    required this.label,
    required this.fallbackIcon,
  });

  final String? assetPath;
  final String label;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildMediaPreview(),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview() {
    if (assetPath == null || assetPath!.trim().isEmpty) {
      return Center(
        child: Icon(
          fallbackIcon,
          color: Colors.white.withValues(alpha: 0.88),
          size: 26,
        ),
      );
    }

    return Lottie.asset(
      assetPath!,
      fit: BoxFit.contain,
      repeat: true,
      frameRate: FrameRate.max,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Icon(
          fallbackIcon,
          color: Colors.white.withValues(alpha: 0.88),
          size: 26,
        ),
      ),
    );
  }
}

class _FallbackVisual extends StatelessWidget {
  const _FallbackVisual({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.2),
        ),
        child: Icon(icon, color: Colors.white, size: 36),
      ),
    );
  }
}
