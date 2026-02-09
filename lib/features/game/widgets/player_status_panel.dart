import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_master/features/game/providers/game_providers.dart';
import 'package:quest_master/shared/widgets/stat_bar.dart';

/// Panel showing player status.
///
/// Adapts based on vision abilities:
/// - Without vision: shows narrative descriptions only
/// - With "Ojo de Verdad": reveals numerical stats
class PlayerStatusPanel extends ConsumerWidget {
  const PlayerStatusPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vision = ref.watch(playerVisionProvider);
    final state = ref.watch(gameStateProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player name and title
            Row(
              children: [
                Icon(Icons.person, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.player.title != null
                        ? '${state.player.name} (${state.player.title})'
                        : state.player.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 16),

            // Health
            StatBar(
              label: 'Salud',
              current: vision.health,
              max: vision.maxHealth,
              narrative: 'Te sientes ${vision.healthNarrative}',
              revealed: vision.canSeeHealth,
              color: _healthColor(vision.health, vision.maxHealth),
              icon: Icons.favorite,
            ),

            // Mana
            StatBar(
              label: 'Mana',
              current: vision.mana,
              max: vision.maxMana,
              narrative: 'Estas ${vision.manaNarrative}',
              revealed: vision.canSeeMana,
              color: Colors.blue,
              icon: Icons.auto_fix_high,
            ),

            // Attack & Defense (only if vision enabled)
            if (vision.canSeeAttack) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  _miniStat(context, 'ATK', vision.attack, Icons.flash_on,
                      Colors.orange),
                  const SizedBox(width: 16),
                  _miniStat(context, 'DEF', vision.defense, Icons.shield,
                      Colors.teal),
                  const SizedBox(width: 16),
                  _miniStat(context, 'VEL', vision.speed,
                      Icons.directions_run, Colors.cyan),
                ],
              ),
            ],

            // Location info
            const Divider(height: 16),
            Row(
              children: [
                Icon(Icons.place, size: 16, color: theme.colorScheme.secondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    state.currentLocation.name,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),

            // Main quest
            if (state.mainQuest != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      state.mainQuest!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.amber,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _miniStat(
    BuildContext context,
    String label,
    int value,
    IconData icon,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Text(
          '$label:$value',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Color _healthColor(int current, int max) {
    final ratio = max > 0 ? current / max : 0.0;
    if (ratio > 0.6) return Colors.green;
    if (ratio > 0.3) return Colors.orange;
    return Colors.red;
  }
}
