import 'package:quest_master/core/constants/game_constants.dart';
import 'package:quest_master/core/models/models.dart';

/// ═══════════════════════════════════════════════════════════════════
/// ContextManager - The brain of Ollama optimization
/// ═══════════════════════════════════════════════════════════════════
///
/// Builds optimized prompts that fit within the AI model's context window.
/// Uses a budget system to allocate tokens across prompt sections.
///
/// Architecture:
/// ┌─────────────────────────────────────────────────┐
/// │               AI Context Window                  │
/// │  ┌─────────────────────────────────────────┐    │
/// │  │ System Instructions     (~200 tokens)    │    │
/// │  ├─────────────────────────────────────────┤    │
/// │  │ Story Summary           (~150 tokens)    │    │
/// │  ├─────────────────────────────────────────┤    │
/// │  │ Key Facts               (~100 tokens)    │    │
/// │  ├─────────────────────────────────────────┤    │
/// │  │ Recent Events           (~400 tokens)    │    │
/// │  ├─────────────────────────────────────────┤    │
/// │  │ Current State           (~150 tokens)    │    │
/// │  ├─────────────────────────────────────────┤    │
/// │  │ Player Input            (variable)       │    │
/// │  └─────────────────────────────────────────┘    │
/// │  ← Response space (~500 tokens) →               │
/// └─────────────────────────────────────────────────┘
class ContextManager {
  final int maxContextTokens;

  ContextManager({
    this.maxContextTokens = GameConstants.maxContextTokens,
  });

  /// Build the complete prompt for the AI model.
  ///
  /// Returns a structured prompt that fits within [maxContextTokens].
  String buildPrompt({
    required GameState state,
    required String playerInput,
  }) {
    final buffer = StringBuffer();

    // 1. System instructions (always included, highest priority)
    final systemInstructions = _buildSystemInstructions(state);
    buffer.writeln(systemInstructions);

    // 2. Story summary (compressed history)
    if (state.storySummary.isNotEmpty) {
      final summary = _truncateToTokens(
        state.storySummary,
        GameConstants.storySummaryBudget,
      );
      buffer.writeln('\n[HISTORIA]: $summary');
    }

    // 3. Key facts (critical persistent information)
    if (state.keyFacts.isNotEmpty) {
      final facts = _buildKeyFacts(state.keyFacts);
      buffer.writeln('\n[HECHOS CLAVE]: $facts');
    }

    // 4. Main quest
    if (state.mainQuest != null) {
      buffer.writeln('\n[MISION]: ${state.mainQuest}');
    }

    // 5. Recent events (last N events in compact format)
    final recentEvents = _buildRecentEvents(state);
    if (recentEvents.isNotEmpty) {
      buffer.writeln('\n[EVENTOS RECIENTES]:\n$recentEvents');
    }

    // 6. Current state (location, NPCs, player status)
    final currentState = _buildCurrentState(state);
    buffer.writeln('\n[ESTADO ACTUAL]: $currentState');

    // 7. Player input
    buffer.writeln('\n[ACCION DEL JUGADOR]: $playerInput');

    // 8. Response instructions
    buffer.writeln(
      '\n[INSTRUCCION]: Narra el resultado de la accion. '
      'Se descriptivo pero conciso (max 3 parrafos). '
      'Incluye consecuencias y cambios en el mundo.',
    );

    return buffer.toString();
  }

  /// Build a prompt specifically for summarization.
  String buildSummarizationPrompt(List<GameEvent> events) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Resume los siguientes eventos de una aventura en 2-3 frases concisas. '
      'Mantiene solo los hechos mas importantes:',
    );
    buffer.writeln();

    for (final event in events) {
      buffer.writeln('> ${event.playerAction}');
      buffer.writeln(event.narrative);
      buffer.writeln();
    }

    buffer.writeln(
      'Resume manteniendo: personajes clave, decisiones importantes, '
      'cambios en el mundo, y items obtenidos/perdidos.',
    );

    return buffer.toString();
  }

  /// Determine if summarization is needed based on event count.
  bool needsSummarization(GameState state) {
    return state.events.length >= GameConstants.summarizationThreshold;
  }

  /// Extract key facts from an AI-generated summary.
  /// Called after summarization to update the key facts list.
  List<String> extractKeyFacts(
    List<String> existingFacts,
    List<GameEvent> newEvents,
  ) {
    // Analyze events for important facts
    final newFacts = <String>[];

    for (final event in newEvents) {
      // Look for item acquisitions, quest changes, NPC encounters
      final changes = event.stateChanges;
      if (changes.containsKey('itemGained')) {
        newFacts.add('Obtuvo: ${changes['itemGained']}');
      }
      if (changes.containsKey('npcMet')) {
        newFacts.add('Conocio a: ${changes['npcMet']}');
      }
      if (changes.containsKey('questUpdate')) {
        newFacts.add('Mision: ${changes['questUpdate']}');
      }
      if (changes.containsKey('worldChange')) {
        newFacts.add('Mundo: ${changes['worldChange']}');
      }
    }

    // Merge and limit
    final allFacts = [...existingFacts, ...newFacts];
    if (allFacts.length > GameConstants.maxKeyFacts) {
      return allFacts.sublist(allFacts.length - GameConstants.maxKeyFacts);
    }
    return allFacts;
  }

  // ── Private Helpers ──

  String _buildSystemInstructions(GameState state) {
    return 'Eres el narrador de una aventura de rol en era ${state.era}. '
        'Narra en segunda persona. Se creativo y descriptivo. '
        'El jugador puede hacer CUALQUIER accion. '
        'Adapta el mundo organicamente a sus decisiones. '
        'NO muestres numeros ni estadisticas en la narrativa. '
        'Describe efectos de forma narrativa '
        '(ej: "te sientes debil" en vez de "-20 HP").';
  }

  String _buildKeyFacts(List<String> facts) {
    final truncated = facts.take(GameConstants.maxKeyFacts).toList();
    return truncated.join('; ');
  }

  String _buildRecentEvents(GameState state) {
    final recent = state.recentEvents(GameConstants.recentEventsCount);
    if (recent.isEmpty) return '';

    final buffer = StringBuffer();
    // Use compact format to save tokens
    for (final event in recent) {
      buffer.writeln(event.toCompact());
    }

    // Truncate if over budget
    return _truncateToTokens(
      buffer.toString(),
      GameConstants.recentEventsBudget,
    );
  }

  String _buildCurrentState(GameState state) {
    final parts = <String>[];

    // Location
    parts.add('Lugar: ${state.currentLocation.name}');
    if (state.currentLocation.description != null) {
      parts.add(state.currentLocation.description!);
    }

    // Player status (narrative form for the AI)
    parts.add('Protagonista: ${state.player.name} '
        '(${state.player.healthNarrative}, ${state.player.manaNarrative})');

    // Active NPCs
    if (state.activeNpcs.isNotEmpty) {
      final npcNames =
          state.activeNpcs.values.map((n) => n.name).join(', ');
      parts.add('Presentes: $npcNames');
    }

    // Equipped items (names only to save tokens)
    final equipped =
        state.inventory.values.where((i) => i.isEquipped).toList();
    if (equipped.isNotEmpty) {
      parts.add('Equipado: ${equipped.map((i) => i.name).join(", ")}');
    }

    return _truncateToTokens(
      parts.join('. '),
      GameConstants.currentStateBudget,
    );
  }

  /// Truncate text to fit within a token budget.
  String _truncateToTokens(String text, int maxTokens) {
    final maxChars = (maxTokens * GameConstants.charsPerToken).toInt();
    if (text.length <= maxChars) return text;
    return '${text.substring(0, maxChars - 3)}...';
  }
}
