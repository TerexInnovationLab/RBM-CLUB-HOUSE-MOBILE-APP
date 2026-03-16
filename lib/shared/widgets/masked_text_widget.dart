import 'package:flutter/material.dart';

/// Displays masked text by default with an eye toggle.
class MaskedTextWidget extends StatefulWidget {
  /// Creates a masked text widget.
  const MaskedTextWidget({
    super.key,
    required this.text,
    this.mask = '••••••',
    this.textStyle,
    this.iconColor,
  });

  /// The real text value.
  final String text;

  /// Mask value.
  final String mask;

  /// Text style.
  final TextStyle? textStyle;

  /// Icon color.
  final Color? iconColor;

  @override
  State<MaskedTextWidget> createState() => _MaskedTextWidgetState();
}

class _MaskedTextWidgetState extends State<MaskedTextWidget> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _revealed ? widget.text : widget.mask,
          style: widget.textStyle,
        ),
        IconButton(
          onPressed: () => setState(() => _revealed = !_revealed),
          icon: Icon(_revealed ? Icons.visibility_off : Icons.visibility),
          color: widget.iconColor,
          tooltip: _revealed ? 'Hide' : 'Show',
        ),
      ],
    );
  }
}

