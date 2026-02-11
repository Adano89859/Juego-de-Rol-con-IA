import 'package:flutter/material.dart';

/// A stat bar that can show either numerical values or narrative descriptions.
///
/// When [revealed] is true, shows the actual numbers with a progress bar.
/// When [revealed] is false, shows only the narrative description.
class StatBar extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final String narrative;
  final bool revealed;
  final Color? color;
  final IconData? icon;

  const StatBar({
    super.key,
    required this.label,
    required this.current,
    required this.max,
    required this.narrative,
    required this.revealed,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColor = color ?? theme.colorScheme.primary;

    if (revealed) {
      return _buildRevealedStat(context, barColor);
    } else {
      return _buildHiddenStat(context);
    }
  }

  Widget _buildRevealedStat(BuildContext context, Color barColor) {
    final ratio = max > 0 ? current / max : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: barColor),
                const SizedBox(width: 4),
              ],
              Text(
                '$label: $current/$max',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: barColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(barColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHiddenStat(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              narrative,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
