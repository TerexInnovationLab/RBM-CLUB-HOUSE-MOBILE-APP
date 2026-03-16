import 'package:flutter/material.dart';

/// FAQ item widget.
class FaqItemWidget extends StatelessWidget {
  /// Creates an FAQ item widget.
  const FaqItemWidget({super.key, required this.question, required this.answer});

  /// Question.
  final String question;

  /// Answer.
  final String answer;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer),
        ),
      ],
    );
  }
}

