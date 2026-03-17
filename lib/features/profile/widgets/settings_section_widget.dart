import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Settings section widget.
class SettingsSectionWidget extends StatelessWidget {
  /// Creates settings section widget.
  const SettingsSectionWidget({
    super.key,
    required this.title,
    required this.children,
  });

  /// Title.
  final String title;

  /// Children tiles.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.inactive,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEFEFEF)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 0),
                  child: children[i],
                ),
                if (i != children.length - 1)
                  const Divider(height: 1, thickness: 1, color: Color(0xFFF8F8F8)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
