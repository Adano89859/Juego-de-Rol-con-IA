import 'package:equatable/equatable.dart';

/// A location in the game world.
class Location extends Equatable {
  final String id;
  final String name;

  // ── Narrative ──
  final String? description;
  final String? atmosphere;
  final String? history;

  // ── World State ──
  final String? era;
  final String? climate;
  final String? timeOfDay;

  // ── Connected Entities ──
  /// IDs of NPCs present at this location
  final List<String> npcIds;

  /// IDs of items that can be found here
  final List<String> itemIds;

  /// IDs of connected locations (exits)
  final Map<String, String> exits; // direction -> location ID

  // ── Dangers & Opportunities ──
  final int dangerLevel; // 0-10
  final List<String> activeEvents;
  final List<String> availableQuests;

  // ── Template / Prefab ──
  final bool isTemplate;
  final String? templateName;
  final DateTime createdAt;

  // ── Extensibility ──
  final Map<String, dynamic> customData;
  final List<String> tags;

  const Location({
    required this.id,
    required this.name,
    this.description,
    this.atmosphere,
    this.history,
    this.era,
    this.climate,
    this.timeOfDay,
    this.npcIds = const [],
    this.itemIds = const [],
    this.exits = const {},
    this.dangerLevel = 0,
    this.activeEvents = const [],
    this.availableQuests = const [],
    this.isTemplate = false,
    this.templateName,
    required this.createdAt,
    this.customData = const {},
    this.tags = const [],
  });

  String toContextString() {
    final parts = <String>[name];
    if (description != null) parts.add(description!);
    if (atmosphere != null) parts.add('Ambiente: $atmosphere');
    if (climate != null) parts.add('Clima: $climate');
    if (dangerLevel > 0) parts.add('Peligro: $dangerLevel/10');
    return parts.join(' | ');
  }

  Location copyWith({
    String? id,
    String? name,
    String? description,
    String? atmosphere,
    String? history,
    String? era,
    String? climate,
    String? timeOfDay,
    List<String>? npcIds,
    List<String>? itemIds,
    Map<String, String>? exits,
    int? dangerLevel,
    List<String>? activeEvents,
    List<String>? availableQuests,
    bool? isTemplate,
    String? templateName,
    DateTime? createdAt,
    Map<String, dynamic>? customData,
    List<String>? tags,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      atmosphere: atmosphere ?? this.atmosphere,
      history: history ?? this.history,
      era: era ?? this.era,
      climate: climate ?? this.climate,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      npcIds: npcIds ?? this.npcIds,
      itemIds: itemIds ?? this.itemIds,
      exits: exits ?? this.exits,
      dangerLevel: dangerLevel ?? this.dangerLevel,
      activeEvents: activeEvents ?? this.activeEvents,
      availableQuests: availableQuests ?? this.availableQuests,
      isTemplate: isTemplate ?? this.isTemplate,
      templateName: templateName ?? this.templateName,
      createdAt: createdAt ?? this.createdAt,
      customData: customData ?? this.customData,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'atmosphere': atmosphere,
        'history': history,
        'era': era,
        'climate': climate,
        'timeOfDay': timeOfDay,
        'npcIds': npcIds,
        'itemIds': itemIds,
        'exits': exits,
        'dangerLevel': dangerLevel,
        'activeEvents': activeEvents,
        'availableQuests': availableQuests,
        'isTemplate': isTemplate,
        'templateName': templateName,
        'createdAt': createdAt.toIso8601String(),
        'customData': customData,
        'tags': tags,
      };

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        atmosphere: json['atmosphere'] as String?,
        history: json['history'] as String?,
        era: json['era'] as String?,
        climate: json['climate'] as String?,
        timeOfDay: json['timeOfDay'] as String?,
        npcIds: (json['npcIds'] as List<dynamic>?)?.cast<String>() ?? [],
        itemIds: (json['itemIds'] as List<dynamic>?)?.cast<String>() ?? [],
        exits: (json['exits'] as Map<String, dynamic>?)
                ?.cast<String, String>() ??
            {},
        dangerLevel: json['dangerLevel'] as int? ?? 0,
        activeEvents:
            (json['activeEvents'] as List<dynamic>?)?.cast<String>() ?? [],
        availableQuests:
            (json['availableQuests'] as List<dynamic>?)?.cast<String>() ?? [],
        isTemplate: json['isTemplate'] as bool? ?? false,
        templateName: json['templateName'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        customData: (json['customData'] as Map<String, dynamic>?) ?? {},
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  @override
  List<Object?> get props => [id];
}
