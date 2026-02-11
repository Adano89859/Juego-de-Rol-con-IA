import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_master/features/settings/providers/settings_providers.dart';

/// Settings screen for AI configuration and app preferences.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── AI Configuration ──
          Text(
            'Configuracion de IA',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Usar IA Mock'),
                  subtitle: const Text(
                    'Respuestas predefinidas para desarrollo',
                  ),
                  value: settings.useMockAI,
                  onChanged: (_) => notifier.toggleMockAI(),
                ),
                if (!settings.useMockAI) ...[
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('URL de Ollama'),
                    subtitle: Text(settings.ollamaUrl),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditDialog(
                      context,
                      'URL de Ollama',
                      settings.ollamaUrl,
                      notifier.updateOllamaUrl,
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Modelo'),
                    subtitle: Text(settings.ollamaModel),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _showEditDialog(
                      context,
                      'Modelo de Ollama',
                      settings.ollamaModel,
                      notifier.updateOllamaModel,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Context Optimization ──
          Text(
            'Optimizacion de Contexto',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Max Tokens de Contexto'),
                  subtitle: Text('${settings.maxContextTokens} tokens'),
                  trailing: SizedBox(
                    width: 150,
                    child: Slider(
                      value: settings.maxContextTokens.toDouble(),
                      min: 500,
                      max: 4000,
                      divisions: 7,
                      label: '${settings.maxContextTokens}',
                      onChanged: (v) => notifier.updateMaxTokens(v.toInt()),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Appearance ──
          Text(
            'Apariencia',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              title: const Text('Modo Oscuro'),
              value: settings.darkMode,
              onChanged: (_) => notifier.toggleDarkMode(),
            ),
          ),

          const SizedBox(height: 24),

          // ── About ──
          Card(
            child: ListTile(
              title: const Text('Quest Master'),
              subtitle: const Text('v1.0.0 - Aventura narrativa con IA'),
              leading: Icon(
                Icons.auto_stories,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String title,
    String currentValue,
    Future<void> Function(String) onSave,
  ) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
