import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, danger }

class _ButtonColors {
  final Color backgroundColor;
  final Color textColor;

  const _ButtonColors({required this.backgroundColor, required this.textColor});
}

extension _ButtonVariantExtension on ButtonVariant {
  _ButtonColors colors(BuildContext context) {
    switch (this) {
      case ButtonVariant.primary:
        return _ButtonColors(
          backgroundColor: Theme.of(context).colorScheme.primary,
          textColor: Theme.of(context).colorScheme.onPrimary,
        );
      case ButtonVariant.secondary:
        return _ButtonColors(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          textColor: Theme.of(context).colorScheme.onSecondary,
        );
      case ButtonVariant.danger:
        return _ButtonColors(
          backgroundColor: Theme.of(context).colorScheme.error,
          textColor: Theme.of(context).colorScheme.onError,
        );
    }
  }
}

class Button extends StatelessWidget {
  final ButtonVariant variant;
  final String text;
  final VoidCallback? onPressed;

  const Button({
    super.key,
    required this.variant,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = variant.colors(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: colors.textColor,
          backgroundColor: colors.backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
