import 'package:flutter/material.dart';

/// Custom numeric keypad for secure PIN entry.
class PinKeypadWidget extends StatelessWidget {
  /// Creates a PIN keypad widget.
  const PinKeypadWidget({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onConfirm,
    this.confirmEnabled = true,
    this.confirmLabel = 'Confirm',
    this.confirmIcon = Icons.check,
  });

  /// Digit handler.
  final ValueChanged<int> onDigit;

  /// Backspace handler.
  final VoidCallback onBackspace;

  /// Confirm handler.
  final VoidCallback onConfirm;

  /// Whether confirm button is enabled.
  final bool confirmEnabled;

  /// Confirm button label.
  final String confirmLabel;

  /// Confirm button icon.
  final IconData confirmIcon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6, // More compact buttons
              children: [
                for (var i = 1; i <= 9; i++)
                  _DigitButton(digit: i, onTap: () => onDigit(i)),
                const SizedBox.shrink(),
                _DigitButton(digit: 0, onTap: () => onDigit(0)),
                _IconButton(
                  icon: Icons.backspace_outlined,
                  onTap: onBackspace,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: confirmEnabled ? onConfirm : null,
                icon: Icon(confirmIcon),
                label: Text(confirmLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DigitButton extends StatelessWidget {
  const _DigitButton({required this.digit, required this.onTap});

  final int digit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: Text(
        '$digit',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      child: Icon(icon),
    );
  }
}
