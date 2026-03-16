import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../routes/route_names.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../../../shared/widgets/rbm_card.dart';

/// Help screen.
class HelpScreen extends StatelessWidget {
  /// Creates a help screen.
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OfflineBanner(
      child: Scaffold(
        appBar: const RbmAppBar(title: AppStrings.helpTitle),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const RbmCard(
              child: Text('For assistance, contact RBM Club House support.'),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.quiz_outlined),
              title: const Text('Frequently Asked Questions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go(RouteNames.faq),
            ),
          ],
        ),
      ),
    );
  }
}
