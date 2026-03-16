import 'package:flutter/material.dart';

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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

