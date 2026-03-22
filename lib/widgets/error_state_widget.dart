import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final String? subtitle;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final double verticalPadding;

  const ErrorStateWidget({
    required this.message,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    super.key,
    this.subtitle,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.verticalPadding = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            if (subtitle != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(subtitle!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onPrimaryPressed,
              child: Text(primaryButtonText),
            ),
            if (secondaryButtonText != null &&
                onSecondaryPressed != null) ...<Widget>[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onSecondaryPressed,
                child: Text(secondaryButtonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
