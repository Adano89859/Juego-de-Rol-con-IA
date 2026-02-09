import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_master/core/models/models.dart';
import 'package:quest_master/features/game/providers/game_providers.dart';
import 'package:quest_master/features/game/widgets/action_input.dart';
import 'package:quest_master/features/game/widgets/player_status_panel.dart';
import 'package:quest_master/features/prefabs/screens/prefab_library_screen.dart';
import 'package:quest_master/features/settings/screens/settings_screen.dart';
import 'package:quest_master/shared/widgets/narrative_bubble.dart';

/// Main game screen with narrative display and action input.
///
/// Layout:
/// ┌──────────────────────────┐
/// │    App Bar (Quest)       │
/// ├──────────────────────────┤
/// │  Player Status Panel     │
/// ├──────────────────────────┤
/// │                          │
/// │  Narrative Scroll View   │
/// │  (chat-like bubbles)     │
/// │                          │
/// ├──────────────────────────┤
/// │  Action Input Bar        │
/// └──────────────────────────┘
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  final _scrollController = ScrollController();
  bool _showStatus = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final events = ref.watch(recentEventsProvider);
    final error = ref.watch(errorProvider);
    final state = ref.watch(gameStateProvider);

    // Auto-scroll when new events arrive
    ref.listen(recentEventsProvider, (_, __) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: Text('Quest Master'),
        actions: [
          // Toggle status panel
          IconButton(
            icon: Icon(
              _showStatus ? Icons.visibility_off : Icons.visibility,
            ),
            tooltip: 'Estado del personaje',
            onPressed: () => setState(() => _showStatus = !_showStatus),
          ),
          // Prefabs library
          IconButton(
            icon: const Icon(Icons.library_books),
            tooltip: 'Prefabs',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PrefabLibraryScreen(),
              ),
            ),
          ),
          // Save situation as prefab
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(value, state),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'save_prefab',
                child: ListTile(
                  leading: Icon(Icons.save),
                  title: Text('Guardar situacion'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'summarize',
                child: ListTile(
                  leading: Icon(Icons.compress),
                  title: Text('Resumir historia'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'new_game',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Nueva partida'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Ajustes'),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Player status panel (collapsible)
          if (_showStatus) const PlayerStatusPanel(),

          // Error banner
          if (error != null)
            MaterialBanner(
              content: Text(error),
              backgroundColor: Colors.red.withValues(alpha: 0.2),
              actions: [
                TextButton(
                  onPressed: () => ref
                      .read(gameStateProvider.notifier)
                      .loadState(state.copyWith(error: null)),
                  child: const Text('Cerrar'),
                ),
              ],
            ),

          // Narrative display
          Expanded(
            child: events.isEmpty
                ? _buildWelcome(context, state)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Column(
                        children: [
                          // Player action
                          NarrativeBubble(
                            text: event.playerAction,
                            isPlayerAction: true,
                          ),
                          // AI narrative
                          NarrativeBubble(
                            text: event.narrative,
                            isPlayerAction: false,
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // Action input
          const ActionInput(),
        ],
      ),
    );
  }

  Widget _buildWelcome(BuildContext context, GameState state) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Quest Master',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.currentLocation.description ?? 'Tu aventura comienza...',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '¿Que haces?',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escribe cualquier accion. Sin limites.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, GameState state) {
    switch (action) {
      case 'save_prefab':
        _showSavePrefabDialog(state);
      case 'summarize':
        ref.read(gameStateProvider.notifier).summarizeHistory();
      case 'new_game':
        _showNewGameDialog();
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        );
    }
  }

  void _showSavePrefabDialog(GameState state) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guardar Situacion'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nombre del prefab',
            hintText: 'ej: Ciudad del Eter Colapsando',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                // Save via prefab service
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Situacion "${nameController.text}" guardada'),
                  ),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showNewGameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Partida'),
        content: const Text(
          '¿Iniciar una nueva aventura? '
          'El progreso actual no guardado se perdera.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(gameStateProvider.notifier).newGame();
              Navigator.pop(context);
            },
            child: const Text('Nueva Aventura'),
          ),
        ],
      ),
    );
  }
}
