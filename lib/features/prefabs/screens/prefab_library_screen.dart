import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_master/core/models/models.dart';
import 'package:quest_master/features/prefabs/providers/prefab_providers.dart';

/// Screen for browsing and managing saved prefabs.
class PrefabLibraryScreen extends ConsumerStatefulWidget {
  const PrefabLibraryScreen({super.key});

  @override
  ConsumerState<PrefabLibraryScreen> createState() =>
      _PrefabLibraryScreenState();
}

class _PrefabLibraryScreenState extends ConsumerState<PrefabLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    (PrefabType.situation, 'Situaciones', Icons.public),
    (PrefabType.character, 'Personajes', Icons.person),
    (PrefabType.item, 'Objetos', Icons.inventory_2),
    (PrefabType.location, 'Lugares', Icons.place),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biblioteca de Prefabs'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs
              .map((t) => Tab(icon: Icon(t.$3), text: t.$2))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs
            .map((t) => _PrefabList(type: t.$1))
            .toList(),
      ),
    );
  }
}

class _PrefabList extends ConsumerWidget {
  final PrefabType type;

  const _PrefabList({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefabsAsync = ref.watch(prefabListProvider(type));

    return prefabsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (prefabs) {
        if (prefabs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _iconForType(type),
                  size: 64,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sin ${_labelForType(type)} guardados',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Guarda elementos durante el juego\npara reutilizarlos aqui',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: prefabs.length,
          itemBuilder: (context, index) {
            final prefab = prefabs[index];
            return _PrefabCard(prefab: prefab);
          },
        );
      },
    );
  }

  IconData _iconForType(PrefabType type) {
    switch (type) {
      case PrefabType.situation:
        return Icons.public;
      case PrefabType.character:
        return Icons.person;
      case PrefabType.item:
        return Icons.inventory_2;
      case PrefabType.enemy:
        return Icons.dangerous;
      case PrefabType.location:
        return Icons.place;
      case PrefabType.climate:
        return Icons.cloud;
    }
  }

  String _labelForType(PrefabType type) {
    switch (type) {
      case PrefabType.situation:
        return 'situaciones';
      case PrefabType.character:
        return 'personajes';
      case PrefabType.item:
        return 'objetos';
      case PrefabType.enemy:
        return 'enemigos';
      case PrefabType.location:
        return 'lugares';
      case PrefabType.climate:
        return 'climas';
    }
  }
}

class _PrefabCard extends ConsumerWidget {
  final Prefab prefab;

  const _PrefabCard({required this.prefab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          child: Icon(
            _iconForType(prefab.type),
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(prefab.name),
        subtitle: prefab.description != null
            ? Text(
                prefab.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'load':
                // Load prefab into game
                break;
              case 'export':
                // Export as JSON
                break;
              case 'delete':
                ref.read(prefabServiceProvider).deletePrefab(prefab.id);
                ref.invalidate(allPrefabsProvider);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'load',
              child: Text('Cargar en partida'),
            ),
            const PopupMenuItem(
              value: 'export',
              child: Text('Exportar JSON'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Eliminar'),
            ),
          ],
        ),
        onTap: () {
          // Show prefab details
          _showPrefabDetails(context, prefab);
        },
      ),
    );
  }

  IconData _iconForType(PrefabType type) {
    switch (type) {
      case PrefabType.situation:
        return Icons.public;
      case PrefabType.character:
        return Icons.person;
      case PrefabType.item:
        return Icons.inventory_2;
      case PrefabType.enemy:
        return Icons.dangerous;
      case PrefabType.location:
        return Icons.place;
      case PrefabType.climate:
        return Icons.cloud;
    }
  }

  void _showPrefabDetails(BuildContext context, Prefab prefab) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(prefab.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (prefab.description != null)
                Text(prefab.description!),
              const SizedBox(height: 8),
              Text(
                'Tipo: ${prefab.type.name}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Creado: ${prefab.createdAt.toString().substring(0, 16)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (prefab.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: prefab.tags
                      .map((t) => Chip(
                            label: Text(t),
                            visualDensity: VisualDensity.compact,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Load into game
            },
            child: const Text('Usar'),
          ),
        ],
      ),
    );
  }
}
