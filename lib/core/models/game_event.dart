import 'package:equatable/equatable.dart';

/// Represents a single event in the game narrative.
/// Events are the atomic unit of story progression.
class GameEvent extends Equatable {
  final String id;
  final DateTime timestamp;

  /// What the player typed / chose
  final String playerAction;

  /// The AI-generated narrative response
  final String narrative;

  /// Structured changes that happened (for state tracking)
  final Map<String, dynamic> stateChanges;

  /// Tags for context relevance scoring (e.g., "combat", "dialogue", "discovery")
  final List<String> tags;

  const GameEvent({
    required this.id,
    required this.timestamp,
    required this.playerAction,
    required this.narrative,
    this.stateChanges = const {},
    this.tags = const [],
  });

  /// Compact representation for context window
  String toCompact() {
    return '> $playerAction\n$narrative';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'playerAction': playerAction,
        'narrative': narrative,
        'stateChanges': stateChanges,
        'tags': tags,
      };

  factory GameEvent.fromJson(Map<String, dynamic> json) => GameEvent(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        playerAction: json['playerAction'] as String,
        narrative: json['narrative'] as String,
        stateChanges: (json['stateChanges'] as Map<String, dynamic>?) ?? {},
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  @override
  List<Object?> get props => [id];
}
