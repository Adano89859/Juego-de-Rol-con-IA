import 'package:quest_master/core/models/models.dart';

/// ═══════════════════════════════════════════════════════════════════
/// Progressive Vision System
/// ═══════════════════════════════════════════════════════════════════
///
/// Controls what information is visible to the player.
///
/// By default, all numerical stats are HIDDEN. The player only sees
/// narrative descriptions ("you feel weak", "the enemy staggers").
///
/// Special items/abilities unlock stat visibility:
///
///   ┌──────────────────────┬─────────────────────────────────┐
///   │ Vision Ability       │ What It Reveals                 │
///   ├──────────────────────┼─────────────────────────────────┤
///   │ Ojo de Verdad        │ Player's own stats (HP, ATK...) │
///   │ Vision Mistica       │ Enemy/NPC stats                 │
///   │ Gafas de Analisis    │ Item properties & bonuses       │
///   └──────────────────────┴─────────────────────────────────┘
///
/// The UI queries VisionSystem to determine what to render.
class VisionSystem {
  /// Determine what stats to show for the player character.
  static PlayerVisionData getPlayerVision(GameState state) {
    final canSeeStats = state.playerHasSelfVision;

    return PlayerVisionData(
      canSeeHealth: canSeeStats,
      canSeeAttack: canSeeStats,
      canSeeDefense: canSeeStats,
      canSeeSpeed: canSeeStats,
      canSeeLuck: canSeeStats,
      canSeeMana: canSeeStats,
      // Narrative descriptions are always available
      healthNarrative: state.player.healthNarrative,
      manaNarrative: state.player.manaNarrative,
      // Actual values (only used if canSee* is true)
      health: state.player.health,
      maxHealth: state.player.maxHealth,
      attack: state.player.attack,
      defense: state.player.defense,
      speed: state.player.speed,
      luck: state.player.luck,
      mana: state.player.mana,
      maxMana: state.player.maxMana,
    );
  }

  /// Determine what stats to show for an NPC/enemy.
  static CharacterVisionData getCharacterVision(
    GameState state,
    Character character,
  ) {
    final canSeeStats = state.playerHasEnemyVision;

    return CharacterVisionData(
      name: character.name,
      title: character.title,
      canSeeStats: canSeeStats,
      healthNarrative: character.healthNarrative,
      health: character.health,
      maxHealth: character.maxHealth,
      attack: character.attack,
      defense: character.defense,
    );
  }

  /// Determine what properties to show for an item.
  static ItemVisionData getItemVision(GameState state, GameItem item) {
    final canSeeProperties = state.playerHasItemVision;

    return ItemVisionData(
      name: item.name,
      type: item.type,
      canSeeProperties: canSeeProperties,
      description: item.description,
      attackBonus: item.attackBonus,
      defenseBonus: item.defenseBonus,
      speedBonus: item.speedBonus,
      healthBonus: item.healthBonus,
      manaBonus: item.manaBonus,
      rarity: item.rarity,
      effects: item.effects,
      // Always show if it's a vision item (so player knows what it does)
      isVisionItem: item.isVisionItem,
    );
  }
}

/// What the UI should display for the player's own stats.
class PlayerVisionData {
  final bool canSeeHealth;
  final bool canSeeAttack;
  final bool canSeeDefense;
  final bool canSeeSpeed;
  final bool canSeeLuck;
  final bool canSeeMana;

  final String healthNarrative;
  final String manaNarrative;

  final int health;
  final int maxHealth;
  final int attack;
  final int defense;
  final int speed;
  final int luck;
  final int mana;
  final int maxMana;

  const PlayerVisionData({
    required this.canSeeHealth,
    required this.canSeeAttack,
    required this.canSeeDefense,
    required this.canSeeSpeed,
    required this.canSeeLuck,
    required this.canSeeMana,
    required this.healthNarrative,
    required this.manaNarrative,
    required this.health,
    required this.maxHealth,
    required this.attack,
    required this.defense,
    required this.speed,
    required this.luck,
    required this.mana,
    required this.maxMana,
  });
}

/// What the UI should display for an NPC/enemy.
class CharacterVisionData {
  final String name;
  final String? title;
  final bool canSeeStats;
  final String healthNarrative;
  final int health;
  final int maxHealth;
  final int attack;
  final int defense;

  const CharacterVisionData({
    required this.name,
    this.title,
    required this.canSeeStats,
    required this.healthNarrative,
    required this.health,
    required this.maxHealth,
    required this.attack,
    required this.defense,
  });
}

/// What the UI should display for an item.
class ItemVisionData {
  final String name;
  final ItemType type;
  final bool canSeeProperties;
  final String? description;
  final int? attackBonus;
  final int? defenseBonus;
  final int? speedBonus;
  final int? healthBonus;
  final int? manaBonus;
  final String? rarity;
  final List<String> effects;
  final bool isVisionItem;

  const ItemVisionData({
    required this.name,
    required this.type,
    required this.canSeeProperties,
    this.description,
    this.attackBonus,
    this.defenseBonus,
    this.speedBonus,
    this.healthBonus,
    this.manaBonus,
    this.rarity,
    this.effects = const [],
    this.isVisionItem = false,
  });
}
