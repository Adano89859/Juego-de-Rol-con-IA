import 'package:equatable/equatable.dart';
import 'package:quest_master/core/models/character.dart';
import 'package:quest_master/core/models/game_event.dart';
import 'package:quest_master/core/models/game_item.dart';
import 'package:quest_master/core/models/location.dart';

/// The complete game state at any point in time.
///
/// This is the single source of truth. Riverpod providers expose
/// slices of this state to UI widgets.
class GameState extends Equatable {
  /// The player character
  final Character player;

  /// Current location
  final Location currentLocation;

  /// NPCs in the current scene
  final Map<String, Character> activeNpcs;

  /// Player's inventory
  final Map<String, GameItem> inventory;

  /// Full event history (trimmed periodically)
  final List<GameEvent> events;

  /// Compressed summary of old events (for AI context)
  final String storySummary;

  /// Critical facts that must always be in AI context
  final List<String> keyFacts;

  /// Current main quest/objective
  final String? mainQuest;

  /// Current era of the world
  final String era;

  /// Turn counter
  final int turnCount;

  /// Is the AI currently generating a response?
  final bool isProcessing;

  /// Last error message (null if no error)
  final String? error;

  /// Known locations (discovered by the player)
  final Map<String, Location> knownLocations;

  /// Custom game-wide data
  final Map<String, dynamic> worldState;

  const GameState({
    required this.player,
    required this.currentLocation,
    this.activeNpcs = const {},
    this.inventory = const {},
    this.events = const [],
    this.storySummary = '',
    this.keyFacts = const [],
    this.mainQuest,
    this.era = 'medieval',
    this.turnCount = 0,
    this.isProcessing = false,
    this.error,
    this.knownLocations = const {},
    this.worldState = const {},
  });

  /// Get recent events (for AI context window).
  List<GameEvent> recentEvents(int count) {
    if (events.length <= count) return events;
    return events.sublist(events.length - count);
  }

  /// Check if player has any vision abilities (from items or innate).
  bool get playerHasSelfVision {
    if (player.hasSelfVision) return true;
    return inventory.values.any((i) => i.isEquipped && i.grantsSelfVision);
  }

  bool get playerHasEnemyVision {
    if (player.hasEnemyVision) return true;
    return inventory.values.any((i) => i.isEquipped && i.grantsEnemyVision);
  }

  bool get playerHasItemVision {
    if (player.hasItemVision) return true;
    return inventory.values.any((i) => i.isEquipped && i.grantsItemVision);
  }

  GameState copyWith({
    Character? player,
    Location? currentLocation,
    Map<String, Character>? activeNpcs,
    Map<String, GameItem>? inventory,
    List<GameEvent>? events,
    String? storySummary,
    List<String>? keyFacts,
    String? mainQuest,
    String? era,
    int? turnCount,
    bool? isProcessing,
    String? error,
    Map<String, Location>? knownLocations,
    Map<String, dynamic>? worldState,
  }) {
    return GameState(
      player: player ?? this.player,
      currentLocation: currentLocation ?? this.currentLocation,
      activeNpcs: activeNpcs ?? this.activeNpcs,
      inventory: inventory ?? this.inventory,
      events: events ?? this.events,
      storySummary: storySummary ?? this.storySummary,
      keyFacts: keyFacts ?? this.keyFacts,
      mainQuest: mainQuest ?? this.mainQuest,
      era: era ?? this.era,
      turnCount: turnCount ?? this.turnCount,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error ?? this.error,
      knownLocations: knownLocations ?? this.knownLocations,
      worldState: worldState ?? this.worldState,
    );
  }

  Map<String, dynamic> toJson() => {
        'player': player.toJson(),
        'currentLocation': currentLocation.toJson(),
        'activeNpcs':
            activeNpcs.map((k, v) => MapEntry(k, v.toJson())),
        'inventory':
            inventory.map((k, v) => MapEntry(k, v.toJson())),
        'events': events.map((e) => e.toJson()).toList(),
        'storySummary': storySummary,
        'keyFacts': keyFacts,
        'mainQuest': mainQuest,
        'era': era,
        'turnCount': turnCount,
        'knownLocations':
            knownLocations.map((k, v) => MapEntry(k, v.toJson())),
        'worldState': worldState,
      };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
        player: Character.fromJson(json['player'] as Map<String, dynamic>),
        currentLocation:
            Location.fromJson(json['currentLocation'] as Map<String, dynamic>),
        activeNpcs: (json['activeNpcs'] as Map<String, dynamic>?)?.map(
                (k, v) =>
                    MapEntry(k, Character.fromJson(v as Map<String, dynamic>))) ??
            {},
        inventory: (json['inventory'] as Map<String, dynamic>?)?.map((k, v) =>
                MapEntry(k, GameItem.fromJson(v as Map<String, dynamic>))) ??
            {},
        events: (json['events'] as List<dynamic>?)
                ?.map((e) => GameEvent.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        storySummary: json['storySummary'] as String? ?? '',
        keyFacts: (json['keyFacts'] as List<dynamic>?)?.cast<String>() ?? [],
        mainQuest: json['mainQuest'] as String?,
        era: json['era'] as String? ?? 'medieval',
        turnCount: json['turnCount'] as int? ?? 0,
        knownLocations: (json['knownLocations'] as Map<String, dynamic>?)?.map(
                (k, v) =>
                    MapEntry(k, Location.fromJson(v as Map<String, dynamic>))) ??
            {},
        worldState: (json['worldState'] as Map<String, dynamic>?) ?? {},
      );

  @override
  List<Object?> get props => [player.id, turnCount, events.length];
}
