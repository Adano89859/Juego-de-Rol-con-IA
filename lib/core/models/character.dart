import 'package:equatable/equatable.dart';
import 'package:quest_master/core/constants/game_constants.dart';

/// Complete character model with hidden stats system.
///
/// Stats exist in code but are hidden from UI until the player
/// acquires vision abilities (e.g., "Ojo de Verdad").
class Character extends Equatable {
  // ── Identity ──
  final String id;
  final String name;
  final String? title; // "the Redeemer", "Shadow King"

  // ── Stats (hidden by default) ──
  final int health;
  final int maxHealth;
  final int attack;
  final int defense;
  final int speed;
  final int luck;
  final int mana;
  final int maxMana;

  // ── Narrative ──
  final String? description;
  final String? backstory;
  final String? currentMood;
  final String? appearance;

  // ── Personality ──
  final String? personality;
  final List<String> motivations;
  final List<String> fears;
  final List<String> secrets;

  // ── Relationships ──
  /// Map of character ID -> relationship description
  final Map<String, String> relationships;

  /// Facts this character knows
  final List<String> knownFacts;

  // ── Abilities ──
  final List<String> abilities;
  final List<String> resistances;
  final List<String> weaknesses;

  // ── Vision Abilities (controls what stats are visible in UI) ──
  /// Can see own stats
  final bool hasSelfVision;

  /// Can see enemy stats
  final bool hasEnemyVision;

  /// Can see item properties
  final bool hasItemVision;

  // ── Temporal Context ──
  final String? era; // "medieval", "steampunk", "futuristic"
  final int? age;

  // ── Inventory ──
  final List<String> inventoryIds;

  // ── Template / Prefab ──
  final bool isTemplate;
  final String? templateName;
  final DateTime createdAt;

  // ── Extensibility ──
  final Map<String, dynamic> customData;
  final List<String> tags;

  const Character({
    required this.id,
    required this.name,
    this.title,
    this.health = GameConstants.defaultHealth,
    this.maxHealth = GameConstants.defaultMaxHealth,
    this.attack = GameConstants.defaultAttack,
    this.defense = GameConstants.defaultDefense,
    this.speed = GameConstants.defaultSpeed,
    this.luck = GameConstants.defaultLuck,
    this.mana = GameConstants.defaultMana,
    this.maxMana = GameConstants.defaultMaxMana,
    this.description,
    this.backstory,
    this.currentMood,
    this.appearance,
    this.personality,
    this.motivations = const [],
    this.fears = const [],
    this.secrets = const [],
    this.relationships = const {},
    this.knownFacts = const [],
    this.abilities = const [],
    this.resistances = const [],
    this.weaknesses = const [],
    this.hasSelfVision = false,
    this.hasEnemyVision = false,
    this.hasItemVision = false,
    this.era,
    this.age,
    this.inventoryIds = const [],
    this.isTemplate = false,
    this.templateName,
    required this.createdAt,
    this.customData = const {},
    this.tags = const [],
  });

  /// Narrative description of health status (used when stats are hidden).
  String get healthNarrative {
    final ratio = health / maxHealth;
    if (ratio >= 0.9) return 'en perfecto estado';
    if (ratio >= 0.7) return 'ligeramente herido';
    if (ratio >= 0.5) return 'herido';
    if (ratio >= 0.3) return 'gravemente herido';
    if (ratio >= 0.1) return 'al borde de la muerte';
    return 'agonizando';
  }

  /// Narrative description of mana status.
  String get manaNarrative {
    final ratio = mana / maxMana;
    if (ratio >= 0.8) return 'rebosante de energía mística';
    if (ratio >= 0.5) return 'con reservas de poder';
    if (ratio >= 0.2) return 'con poca energía mágica';
    return 'agotado mágicamente';
  }

  /// Compact representation for AI context (minimal tokens).
  String toContextString() {
    final parts = <String>[name];
    if (title != null) parts.add('($title)');
    parts.add('HP:$health/$maxHealth ATK:$attack DEF:$defense');
    if (abilities.isNotEmpty) {
      parts.add('Habilidades: ${abilities.join(", ")}');
    }
    if (currentMood != null) parts.add('Estado: $currentMood');
    return parts.join(' | ');
  }

  Character copyWith({
    String? id,
    String? name,
    String? title,
    int? health,
    int? maxHealth,
    int? attack,
    int? defense,
    int? speed,
    int? luck,
    int? mana,
    int? maxMana,
    String? description,
    String? backstory,
    String? currentMood,
    String? appearance,
    String? personality,
    List<String>? motivations,
    List<String>? fears,
    List<String>? secrets,
    Map<String, String>? relationships,
    List<String>? knownFacts,
    List<String>? abilities,
    List<String>? resistances,
    List<String>? weaknesses,
    bool? hasSelfVision,
    bool? hasEnemyVision,
    bool? hasItemVision,
    String? era,
    int? age,
    List<String>? inventoryIds,
    bool? isTemplate,
    String? templateName,
    DateTime? createdAt,
    Map<String, dynamic>? customData,
    List<String>? tags,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      health: health ?? this.health,
      maxHealth: maxHealth ?? this.maxHealth,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      speed: speed ?? this.speed,
      luck: luck ?? this.luck,
      mana: mana ?? this.mana,
      maxMana: maxMana ?? this.maxMana,
      description: description ?? this.description,
      backstory: backstory ?? this.backstory,
      currentMood: currentMood ?? this.currentMood,
      appearance: appearance ?? this.appearance,
      personality: personality ?? this.personality,
      motivations: motivations ?? this.motivations,
      fears: fears ?? this.fears,
      secrets: secrets ?? this.secrets,
      relationships: relationships ?? this.relationships,
      knownFacts: knownFacts ?? this.knownFacts,
      abilities: abilities ?? this.abilities,
      resistances: resistances ?? this.resistances,
      weaknesses: weaknesses ?? this.weaknesses,
      hasSelfVision: hasSelfVision ?? this.hasSelfVision,
      hasEnemyVision: hasEnemyVision ?? this.hasEnemyVision,
      hasItemVision: hasItemVision ?? this.hasItemVision,
      era: era ?? this.era,
      age: age ?? this.age,
      inventoryIds: inventoryIds ?? this.inventoryIds,
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
        'title': title,
        'health': health,
        'maxHealth': maxHealth,
        'attack': attack,
        'defense': defense,
        'speed': speed,
        'luck': luck,
        'mana': mana,
        'maxMana': maxMana,
        'description': description,
        'backstory': backstory,
        'currentMood': currentMood,
        'appearance': appearance,
        'personality': personality,
        'motivations': motivations,
        'fears': fears,
        'secrets': secrets,
        'relationships': relationships,
        'knownFacts': knownFacts,
        'abilities': abilities,
        'resistances': resistances,
        'weaknesses': weaknesses,
        'hasSelfVision': hasSelfVision,
        'hasEnemyVision': hasEnemyVision,
        'hasItemVision': hasItemVision,
        'era': era,
        'age': age,
        'inventoryIds': inventoryIds,
        'isTemplate': isTemplate,
        'templateName': templateName,
        'createdAt': createdAt.toIso8601String(),
        'customData': customData,
        'tags': tags,
      };

  factory Character.fromJson(Map<String, dynamic> json) => Character(
        id: json['id'] as String,
        name: json['name'] as String,
        title: json['title'] as String?,
        health: json['health'] as int? ?? GameConstants.defaultHealth,
        maxHealth: json['maxHealth'] as int? ?? GameConstants.defaultMaxHealth,
        attack: json['attack'] as int? ?? GameConstants.defaultAttack,
        defense: json['defense'] as int? ?? GameConstants.defaultDefense,
        speed: json['speed'] as int? ?? GameConstants.defaultSpeed,
        luck: json['luck'] as int? ?? GameConstants.defaultLuck,
        mana: json['mana'] as int? ?? GameConstants.defaultMana,
        maxMana: json['maxMana'] as int? ?? GameConstants.defaultMaxMana,
        description: json['description'] as String?,
        backstory: json['backstory'] as String?,
        currentMood: json['currentMood'] as String?,
        appearance: json['appearance'] as String?,
        personality: json['personality'] as String?,
        motivations:
            (json['motivations'] as List<dynamic>?)?.cast<String>() ?? [],
        fears: (json['fears'] as List<dynamic>?)?.cast<String>() ?? [],
        secrets: (json['secrets'] as List<dynamic>?)?.cast<String>() ?? [],
        relationships:
            (json['relationships'] as Map<String, dynamic>?)?.cast<String, String>() ??
                {},
        knownFacts:
            (json['knownFacts'] as List<dynamic>?)?.cast<String>() ?? [],
        abilities:
            (json['abilities'] as List<dynamic>?)?.cast<String>() ?? [],
        resistances:
            (json['resistances'] as List<dynamic>?)?.cast<String>() ?? [],
        weaknesses:
            (json['weaknesses'] as List<dynamic>?)?.cast<String>() ?? [],
        hasSelfVision: json['hasSelfVision'] as bool? ?? false,
        hasEnemyVision: json['hasEnemyVision'] as bool? ?? false,
        hasItemVision: json['hasItemVision'] as bool? ?? false,
        era: json['era'] as String?,
        age: json['age'] as int?,
        inventoryIds:
            (json['inventoryIds'] as List<dynamic>?)?.cast<String>() ?? [],
        isTemplate: json['isTemplate'] as bool? ?? false,
        templateName: json['templateName'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        customData:
            (json['customData'] as Map<String, dynamic>?) ?? {},
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  @override
  List<Object?> get props => [id];
}
