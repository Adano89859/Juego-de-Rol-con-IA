import 'package:equatable/equatable.dart';

/// Types of items in the game world.
enum ItemType {
  weapon,
  armor,
  consumable,
  quest,
  vision, // Special: reveals hidden stats
  material,
  artifact,
  tool,
  misc,
}

/// A game item with hidden properties system.
///
/// Item stats are hidden unless the player has [hasItemVision].
/// Vision items are special: they grant the ability to see stats.
class GameItem extends Equatable {
  // ── Identity ──
  final String id;
  final String name;
  final ItemType type;

  // ── Stats (hidden by default) ──
  final int? attackBonus;
  final int? defenseBonus;
  final int? speedBonus;
  final int? healthBonus;
  final int? manaBonus;

  // ── Narrative ──
  final String? description;
  final String? lore;
  final String? appearance;

  // ── Effects ──
  final List<String> effects;
  final List<String> specialAbilities;

  // ── Vision Grants (for vision-type items) ──
  /// Grants the ability to see own stats
  final bool grantsSelfVision;

  /// Grants the ability to see enemy stats
  final bool grantsEnemyVision;

  /// Grants the ability to see item properties
  final bool grantsItemVision;

  // ── Rarity & Value ──
  final String? rarity; // "common", "rare", "legendary", etc.
  final int? value;

  // ── Context ──
  final String? era;
  final bool isEquipped;
  final int quantity;

  // ── Template / Prefab ──
  final bool isTemplate;
  final String? templateName;
  final DateTime createdAt;

  // ── Extensibility ──
  final Map<String, dynamic> customData;
  final List<String> tags;

  const GameItem({
    required this.id,
    required this.name,
    this.type = ItemType.misc,
    this.attackBonus,
    this.defenseBonus,
    this.speedBonus,
    this.healthBonus,
    this.manaBonus,
    this.description,
    this.lore,
    this.appearance,
    this.effects = const [],
    this.specialAbilities = const [],
    this.grantsSelfVision = false,
    this.grantsEnemyVision = false,
    this.grantsItemVision = false,
    this.rarity,
    this.value,
    this.era,
    this.isEquipped = false,
    this.quantity = 1,
    this.isTemplate = false,
    this.templateName,
    required this.createdAt,
    this.customData = const {},
    this.tags = const [],
  });

  /// Whether this item reveals any hidden information.
  bool get isVisionItem =>
      grantsSelfVision || grantsEnemyVision || grantsItemVision;

  /// Compact representation for AI context.
  String toContextString() {
    final parts = <String>[name];
    if (type != ItemType.misc) parts.add('[${type.name}]');
    if (attackBonus != null && attackBonus! > 0) parts.add('+$attackBonus ATK');
    if (defenseBonus != null && defenseBonus! > 0) {
      parts.add('+$defenseBonus DEF');
    }
    if (effects.isNotEmpty) parts.add('(${effects.join(", ")})');
    return parts.join(' ');
  }

  GameItem copyWith({
    String? id,
    String? name,
    ItemType? type,
    int? attackBonus,
    int? defenseBonus,
    int? speedBonus,
    int? healthBonus,
    int? manaBonus,
    String? description,
    String? lore,
    String? appearance,
    List<String>? effects,
    List<String>? specialAbilities,
    bool? grantsSelfVision,
    bool? grantsEnemyVision,
    bool? grantsItemVision,
    String? rarity,
    int? value,
    String? era,
    bool? isEquipped,
    int? quantity,
    bool? isTemplate,
    String? templateName,
    DateTime? createdAt,
    Map<String, dynamic>? customData,
    List<String>? tags,
  }) {
    return GameItem(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      attackBonus: attackBonus ?? this.attackBonus,
      defenseBonus: defenseBonus ?? this.defenseBonus,
      speedBonus: speedBonus ?? this.speedBonus,
      healthBonus: healthBonus ?? this.healthBonus,
      manaBonus: manaBonus ?? this.manaBonus,
      description: description ?? this.description,
      lore: lore ?? this.lore,
      appearance: appearance ?? this.appearance,
      effects: effects ?? this.effects,
      specialAbilities: specialAbilities ?? this.specialAbilities,
      grantsSelfVision: grantsSelfVision ?? this.grantsSelfVision,
      grantsEnemyVision: grantsEnemyVision ?? this.grantsEnemyVision,
      grantsItemVision: grantsItemVision ?? this.grantsItemVision,
      rarity: rarity ?? this.rarity,
      value: value ?? this.value,
      era: era ?? this.era,
      isEquipped: isEquipped ?? this.isEquipped,
      quantity: quantity ?? this.quantity,
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
        'type': type.name,
        'attackBonus': attackBonus,
        'defenseBonus': defenseBonus,
        'speedBonus': speedBonus,
        'healthBonus': healthBonus,
        'manaBonus': manaBonus,
        'description': description,
        'lore': lore,
        'appearance': appearance,
        'effects': effects,
        'specialAbilities': specialAbilities,
        'grantsSelfVision': grantsSelfVision,
        'grantsEnemyVision': grantsEnemyVision,
        'grantsItemVision': grantsItemVision,
        'rarity': rarity,
        'value': value,
        'era': era,
        'isEquipped': isEquipped,
        'quantity': quantity,
        'isTemplate': isTemplate,
        'templateName': templateName,
        'createdAt': createdAt.toIso8601String(),
        'customData': customData,
        'tags': tags,
      };

  factory GameItem.fromJson(Map<String, dynamic> json) => GameItem(
        id: json['id'] as String,
        name: json['name'] as String,
        type: ItemType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => ItemType.misc,
        ),
        attackBonus: json['attackBonus'] as int?,
        defenseBonus: json['defenseBonus'] as int?,
        speedBonus: json['speedBonus'] as int?,
        healthBonus: json['healthBonus'] as int?,
        manaBonus: json['manaBonus'] as int?,
        description: json['description'] as String?,
        lore: json['lore'] as String?,
        appearance: json['appearance'] as String?,
        effects: (json['effects'] as List<dynamic>?)?.cast<String>() ?? [],
        specialAbilities:
            (json['specialAbilities'] as List<dynamic>?)?.cast<String>() ?? [],
        grantsSelfVision: json['grantsSelfVision'] as bool? ?? false,
        grantsEnemyVision: json['grantsEnemyVision'] as bool? ?? false,
        grantsItemVision: json['grantsItemVision'] as bool? ?? false,
        rarity: json['rarity'] as String?,
        value: json['value'] as int?,
        era: json['era'] as String?,
        isEquipped: json['isEquipped'] as bool? ?? false,
        quantity: json['quantity'] as int? ?? 1,
        isTemplate: json['isTemplate'] as bool? ?? false,
        templateName: json['templateName'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        customData: (json['customData'] as Map<String, dynamic>?) ?? {},
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  @override
  List<Object?> get props => [id];
}
