import 'package:flutter/material.dart';

/// A narrative text bubble for displaying game events.
///
/// Player actions are shown right-aligned, AI narrative left-aligned,
/// similar to a chat interface but themed for RPG.
class NarrativeBubble extends StatelessWidget {
  final String text;
  final bool isPlayerAction;
  final DateTime? timestamp;

  const NarrativeBubble({
    super.key,
    required this.text,
    this.isPlayerAction = false,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment:
          isPlayerAction ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isPlayerAction
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : theme.cardTheme.color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isPlayerAction ? 16 : 4),
            bottomRight: Radius.circular(isPlayerAction ? 4 : 16),
          ),
          border: isPlayerAction
              ? Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPlayerAction)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Tu accion:',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                fontStyle:
                    isPlayerAction ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
