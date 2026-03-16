import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/rbm_app_bar.dart';
import '../widgets/faq_item_widget.dart';

/// FAQ screen.
class FaqScreen extends StatelessWidget {
  /// Creates an FAQ screen.
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OfflineBanner(
      child: Scaffold(
        appBar: const RbmAppBar(title: AppStrings.faqTitle),
        body: ListView(
          children: const [
            FaqItemWidget(
              question: 'How do I activate my account?',
              answer: 'Use your Employee Number and temporary PIN from HR, then set a new 6-digit PIN.',
            ),
            FaqItemWidget(
              question: 'What if I forget my PIN?',
              answer: 'After 5 failed attempts your account is locked. Contact HR to unlock/reset.',
            ),
            FaqItemWidget(
              question: 'Why is my balance masked?',
              answer: 'Balances are masked by default to protect sensitive financial information.',
            ),
          ],
        ),
      ),
    );
  }
}

