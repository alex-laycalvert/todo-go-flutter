import 'package:flutter/material.dart';

enum AlertVariant { error }

class _AlertColors {
  final Color textColor;
  final Color iconColor;
  final Color borderColor;
  final Color backgroundColor;

  _AlertColors({
    required this.textColor,
    required this.iconColor,
    required this.borderColor,
    required this.backgroundColor,
  });
}

extension _AlertVariantExtension on AlertVariant {
  _AlertColors colors(BuildContext context) {
    switch (this) {
      case AlertVariant.error:
        return _AlertColors(
          textColor: Theme.of(context).colorScheme.onErrorContainer,
          iconColor: Theme.of(context).colorScheme.error,
          borderColor: Theme.of(context).colorScheme.error,
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
        );
    }
  }
}

class Alert extends StatelessWidget {
  final AlertVariant variant;
  final String message;

  const Alert({super.key, required this.variant, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = variant.colors(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: colors.textColor)),
          ),
        ],
      ),
    );
  }
}
