import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quest_master/core/constants/game_constants.dart';
import 'package:quest_master/core/models/models.dart';
import 'package:quest_master/core/services/services.dart';
import 'package:quest_master/core/utils/vision_system.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// ═══════════════════════════════════════════════════════════════════
// Service Providers
// ═══════════════════════════════════════════════════════════════════

/// AI Service provider - override this in tests with MockAIService.
final aiServiceProvider = Provider<AIService>((ref) {
  return MockAIService();
});

/// Context manager for building optimized prompts.
final contextManagerProvider = Provider<ContextManager>((ref) {
  return ContextManager();
});

// ═══════════════════════════════════════════════════════════════════
// Game State Provider
// ═══════════════════════════════════════════════════════════════════

/// Main game state notifier - the heart of the game logic.
final gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier(
    aiService: ref.watch(aiServiceProvider),
    contextManager: ref.watch(contextManagerProvider),
  );
});

/// Creates initial game state for a new game.
GameState createInitialGameState({String playerName = 'Aventurero'}) {
  final now = DateTime.now();
  return GameState(
    player: Character(
      id: _uuid.v4(),
      name: playerName,
      description: 'Un aventurero en busca de su destino',
      health: GameConstants.defaultHealth,
      maxHealth: GameConstants.defaultMaxHealth,
      attack: GameConstants.defaultAttack,
      defense: GameConstants.defaultDefense,
      speed: GameConstants.defaultSpeed,
      luck: GameConstants.defaultLuck,
      mana: GameConstants.defaultMana,
      maxMana: GameConstants.defaultMaxMana,
      createdAt: now,
    ),
    currentLocation: Location(
      id: _uuid.v4(),
      name: 'Encrucijada del Destino',
      description:
          'Un cruce de caminos donde tres senderos se encuentran. '
          'Un viejo poste de madera señala direcciones apenas legibles. '
          'El viento sopla suavemente, trayendo aromas de lugares lejanos.',
      atmosphere: 'Tranquilo pero misterioso',
      era: 'medieval',
      dangerLevel: 1,
      createdAt: now,
    ),
    era: 'medieval',
    mainQuest: 'Descubre tu destino en este mundo',
    keyFacts: [
      'Inicio de la aventura en la Encrucijada del Destino',
    ],
  );
}

/// Central game state manager.
class GameStateNotifier extends StateNotifier<GameState> {
  final AIService aiService;
  final ContextManager contextManager;

  GameStateNotifier({
    required this.aiService,
    required this.contextManager,
    GameState? initialState,
  }) : super(initialState ?? createInitialGameState());

  /// Process a player action through the AI.
  Future<void> processAction(String playerInput) async {
    if (state.isProcessing) return;
    if (playerInput.trim().isEmpty) return;

    // Mark as processing
    state = state.copyWith(isProcessing: true, error: null);

    try {
      // Check if summarization is needed before building prompt
      if (contextManager.needsSummarization(state)) {
        await _performSummarization();
      }

      // Build optimized prompt
      final prompt = contextManager.buildPrompt(
        state: state,
        playerInput: playerInput,
      );

      // Get AI response
      final response = await aiService.narrate(prompt: prompt);

      // Create new event
      final event = GameEvent(
        id: _uuid.v4(),
        timestamp: DateTime.now(),
        playerAction: playerInput,
        narrative: response.narrative,
        stateChanges: response.stateChanges,
      );

      // Update state
      state = state.copyWith(
        events: [...state.events, event],
        turnCount: state.turnCount + 1,
        isProcessing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: 'Error al procesar: $e',
      );
    }
  }

  /// Manually trigger summarization of old events.
  Future<void> summarizeHistory() async {
    await _performSummarization();
  }

  /// Update the main quest objective.
  void updateMainQuest(String quest) {
    state = state.copyWith(mainQuest: quest);
  }

  /// Add a key fact to persistent context.
  void addKeyFact(String fact) {
    final facts = [...state.keyFacts, fact];
    if (facts.length > GameConstants.maxKeyFacts) {
      facts.removeAt(0);
    }
    state = state.copyWith(keyFacts: facts);
  }

  /// Add an item to the player's inventory.
  void addItem(GameItem item) {
    final inventory = Map<String, GameItem>.from(state.inventory);
    inventory[item.id] = item;

    // Check if item grants vision abilities
    var player = state.player;
    if (item.grantsSelfVision) {
      player = player.copyWith(hasSelfVision: true);
    }
    if (item.grantsEnemyVision) {
      player = player.copyWith(hasEnemyVision: true);
    }
    if (item.grantsItemVision) {
      player = player.copyWith(hasItemVision: true);
    }

    state = state.copyWith(inventory: inventory, player: player);
  }

  /// Toggle item equip state.
  void toggleEquipItem(String itemId) {
    final inventory = Map<String, GameItem>.from(state.inventory);
    final item = inventory[itemId];
    if (item == null) return;

    inventory[itemId] = item.copyWith(isEquipped: !item.isEquipped);
    state = state.copyWith(inventory: inventory);
  }

  /// Add an NPC to the current scene.
  void addNpc(Character npc) {
    final npcs = Map<String, Character>.from(state.activeNpcs);
    npcs[npc.id] = npc;
    state = state.copyWith(activeNpcs: npcs);
  }

  /// Move to a new location.
  void moveToLocation(Location location) {
    final known = Map<String, Location>.from(state.knownLocations);
    known[location.id] = location;
    state = state.copyWith(
      currentLocation: location,
      knownLocations: known,
      activeNpcs: {}, // Clear NPCs when changing location
    );
  }

  /// Load a game state (from save or prefab).
  void loadState(GameState newState) {
    state = newState;
  }

  /// Start a new game.
  void newGame({String playerName = 'Aventurero'}) {
    state = createInitialGameState(playerName: playerName);
  }

  /// Internal: perform event summarization.
  Future<void> _performSummarization() async {
    final eventsToSummarize =
        state.events.take(state.events.length - GameConstants.recentEventsCount).toList();

    if (eventsToSummarize.isEmpty) return;

    final summaryPrompt = contextManager.buildSummarizationPrompt(
      eventsToSummarize,
    );

    final newSummary = await aiService.summarize(prompt: summaryPrompt);

    // Extract and update key facts
    final newFacts = contextManager.extractKeyFacts(
      state.keyFacts,
      eventsToSummarize,
    );

    // Keep only recent events
    final recentEvents =
        state.events.sublist(state.events.length - GameConstants.recentEventsCount);

    final combinedSummary = state.storySummary.isEmpty
        ? newSummary
        : '${state.storySummary} $newSummary';

    state = state.copyWith(
      storySummary: combinedSummary,
      keyFacts: newFacts,
      events: recentEvents,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// Derived Providers (UI-focused)
// ═══════════════════════════════════════════════════════════════════

/// Player vision data (what stats to show in UI).
final playerVisionProvider = Provider<PlayerVisionData>((ref) {
  final state = ref.watch(gameStateProvider);
  return VisionSystem.getPlayerVision(state);
});

/// Whether the game is currently processing an AI request.
final isProcessingProvider = Provider<bool>((ref) {
  return ref.watch(gameStateProvider).isProcessing;
});

/// Current error message (null if no error).
final errorProvider = Provider<String?>((ref) {
  return ref.watch(gameStateProvider).error;
});

/// Recent events for the narrative display.
final recentEventsProvider = Provider<List<GameEvent>>((ref) {
  final state = ref.watch(gameStateProvider);
  return state.recentEvents(20);
});

/// Current location.
final currentLocationProvider = Provider<Location>((ref) {
  return ref.watch(gameStateProvider).currentLocation;
});

/// Player inventory.
final inventoryProvider = Provider<Map<String, GameItem>>((ref) {
  return ref.watch(gameStateProvider).inventory;
});
