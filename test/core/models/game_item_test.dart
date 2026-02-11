import 'package:flutter_test/flutter_test.dart';
import 'package:quest_master/core/models/game_item.dart';

void main() {
  group('GameItem', () {
    test('vision item detection', () {
      final normalSword = GameItem(
        id: 'sword-1',
        name: 'Espada de Hierro',
        type: ItemType.weapon,
        attackBonus: 5,
        createdAt: DateTime(2025, 1, 1),
      );
      expect(normalSword.isVisionItem, false);

      final trueEye = GameItem(
        id: 'eye-1',
        name: 'Ojo de Verdad',
        type: ItemType.vision,
        grantsSelfVision: true,
        description: 'Te permite ver tus propias estadisticas',
        createdAt: DateTime(2025, 1, 1),
      );
      expect(trueEye.isVisionItem, true);
      expect(trueEye.grantsSelfVision, true);
      expect(trueEye.grantsEnemyVision, false);

      final mysticVision = GameItem(
        id: 'vis-1',
        name: 'Vision Mistica',
        type: ItemType.vision,
        grantsEnemyVision: true,
        createdAt: DateTime(2025, 1, 1),
      );
      expect(mysticVision.isVisionItem, true);
      expect(mysticVision.grantsEnemyVision, true);
    });

    test('toJson and fromJson roundtrip', () {
      final item = GameItem(
        id: 'art-1',
        name: 'Espada de las Mil Almas',
        type: ItemType.artifact,
        attackBonus: 25,
        defenseBonus: 5,
        description: 'Una espada que contiene mil almas guerreras',
        lore: 'Forjada en la era de las guerras celestiales',
        rarity: 'legendary',
        effects: ['Daño de almas', 'Absorcion vital'],
        specialAbilities: ['Despertar de las Mil Almas'],
        createdAt: DateTime(2025, 1, 1),
        tags: ['arma', 'legendaria', 'almas'],
      );

      final json = item.toJson();
      final restored = GameItem.fromJson(json);

      expect(restored.id, item.id);
      expect(restored.name, item.name);
      expect(restored.type, ItemType.artifact);
      expect(restored.attackBonus, 25);
      expect(restored.defenseBonus, 5);
      expect(restored.rarity, 'legendary');
      expect(restored.effects.length, 2);
      expect(restored.tags.length, 3);
    });

    test('toContextString produces compact output', () {
      final item = GameItem(
        id: 'w-1',
        name: 'Hacha de Guerra',
        type: ItemType.weapon,
        attackBonus: 12,
        effects: ['Sangrado'],
        createdAt: DateTime(2025, 1, 1),
      );

      final ctx = item.toContextString();
      expect(ctx, contains('Hacha de Guerra'));
      expect(ctx, contains('[weapon]'));
      expect(ctx, contains('+12 ATK'));
      expect(ctx, contains('Sangrado'));
    });
  });
}
